# frozen_string_literal: true

require 'openai'

class WeeklySummaryGenerator
  attr_reader :start_date, :end_date

  def initialize(start_date: 1.week.ago, end_date: Time.current)
    @start_date = start_date
    @end_date = end_date
    @client = OpenAI::Client.new(access_token: Rails.application.credentials.openai_api_key)
  end

  def generate_summary
    news_data = {
      meta:,
      news_items:
    }

    response = call_openai(news_data)

    {
      meta: news_data[:meta],
      summary: parse_ai_response(response),
      raw_response: response
    }
  end

  private

  def meta
    @_meta ||= {
      calendar_week: Date.current.cweek,
      year: Date.current.year,
      start_date: start_date.to_date.iso8601,
      end_date: end_date.to_date.iso8601,
      total_items: news_items_count,
      generated_at: Time.current.iso8601
    }
  end

  def news_items
    NewsItem.visible
      .includes(:source, :categories)
      .where(created_at: start_date..end_date)
      .map { |item| format_news_item(item) }
  end

  def format_news_item(item)
    {
      title: item.title,
      url: include_url?(item) ? item.url : nil,
      source: item.source.name,
      trust:
        case item.source.multiplicator
        when 0...1 then 'low'
        when 1...2 then 'normal'
        when 2...3 then 'high'
        else 'critical'
        end,
      priority:
        if item.source.name&.downcase&.include?('empfehlungsbund')
          "critical"
        else
          case item.absolute_score
          when 100.. then 'high'
          when 50...100 then 'medium'
          when 20...50 then 'normal'
          else 'low'
          end
        end,
      text: item.plaintext&.squish,
      created_at: item.created_at.iso8601,
      score: item.absolute_score,
      has_full_text: item.plaintext.present? && item.plaintext.length > 500
    }
  end

  def include_url?(item)
    return true if item.plaintext.blank?

    item.plaintext.squish.length <= 500
  end

  def news_items_count
    @news_items_count ||= NewsItem.visible
      .where(created_at: start_date..end_date)
      .count
  end

  def build_prompt
    <<~PROMPT
      Erstelle aus dem JSON mit HR-bezogenen Artikeln den „HR-Wochenspiegel" als Blogeintrag für KW #{Date.current.cweek}/#{Date.current.year}.

      Zielgruppe: Employer Branding Manager, Bewerbermanager, Recruiter, Hiring-Manager, Geschäftsführer und ähnliche mit Personalbedarf.

      WICHTIG:
      1. Priorisiere Empfehlungsbund-Inhalte (priority: "critical" oder source enthält "Empfehlungsbund")
      2. Fokussiere auf ungewöhnliche, strategisch relevante und wissenschaftlich fundierte Themen
      3. Filtere Standardthemen, Bewerbertipps und Clickbait heraus
      4. Bevorzuge: Studien, Gerichtsurteile mit Aktenzeichen, Marktanalysen, arbeitsrechtliche Änderungen
      5. Bei Spannend klingenden Headlines, die aber keinen fulltext dabei haben, kannst du vereinzelt versuchen den Inhalt zu recherchieren (URL abrufen).

      Erstelle einen Markdown-formatierten Blog mit:
      - H1-Headline: „HRfilter Wochenspiegel: [prägnante Headline]"
      - Kurze Einleitung (2-3 Sätze) mit KW-Angabe
      - 3-5 thematische Cluster, z.B.:
        * "KI & Compliance im HR"
        * "Führung & New Work"
        * "Arbeitsmarkt- & Recruiting-Trends"
        * "Alternative Wege der Fachkräftegewinnung"
        * "Kollaborative Recruiting-Strategien"
        * "Empfehlungen als Recruiting-Kanal"
        * usw.

      Jeder Cluster:
      - Eigene Headline
      - Zusammenfassender Absatz
      - 2-5 Artikel als Bulletpoints: Titel, Kernaussage, Quelle, Link (falls vorhanden), Datum

      Abschluss:
      - Hinweis auf HRfilter.de und Empfehlungsbund
      - Maximal 12 relevante Hashtags

      Schreibe kontrovers, hinterfragend aber zukunftsoptimistisch.
      Nutze deutsche Sprache, behalte englische Fachbegriffe bei.

      WICHTIG: Antworte im JSON-Format mit folgender Struktur:
      {
        "headline": "HR-Wochenspiegel: [Deine Headline]",
        "introduction": "Einleitungstext",
        "clusters": [
          {
            "title": "Clustername",
            "summary": "Zusammenfassender Absatz",
            "articles": [
              {
                "title": "Artikeltitel",
                "core_message": "Kernaussage",
                "source": "Quelle",
                "url": "Link (optional)",
                "date": "Datum"
              }
            ]
          }
        ],
        "conclusion": "Abschlusstext mit Verweis auf HRfilter und Empfehlungsbund",
        "hashtags": ["hashtag1", "hashtag2"],
        "blog_post": "Der komplette Blogpost als Markdown-Text"
      }
    PROMPT
  end

  def call_openai(news_data)
    # Create temporary file with news data
    temp_file = Tempfile.new(['weekly_news', '.json'])
    temp_file.write(JSON.pretty_generate(news_data))
    temp_file.rewind

    # Upload file to OpenAI
    file_response = @client.files.upload(
      parameters: {
        file: temp_file.path,
        purpose: 'assistants'
      }
    )
    file_id = file_response['id']

    # Create assistant with file_search capability
    assistant = @client.assistants.create(
      parameters: {
        model: 'gpt-4o',
        name: 'HR Weekly Summary Generator',
        instructions: 'Du bist ein HR-Experte und Journalist, der wöchentliche Zusammenfassungen für ' \
                      'HR-Professionals erstellt. Antworte immer im angeforderten JSON-Format.',
        tools: [{ type: 'file_search' }],
        response_format: { type: 'json_object' }
      }
    )

    # Create thread
    thread = @client.threads.create

    # Add message with file attachment
    @client.messages.create(
      thread_id: thread['id'],
      parameters: {
        role: 'user',
        content: build_prompt,
        attachments: [
          {
            file_id:,
            tools: [{ type: 'file_search' }]
          }
        ]
      }
    )

    # Run assistant
    run = @client.runs.create(
      thread_id: thread['id'],
      parameters: {
        assistant_id: assistant['id']
      }
    )

    # Wait for completion
    statuses = ['queued', 'in_progress', 'cancelling']
    while statuses.include?(run['status'])
      sleep 1
      run = @client.runs.retrieve(thread_id: thread['id'], id: run['id'])
    end

    # Get messages
    messages = @client.messages.list(thread_id: thread['id'])
    response = messages['data'].first['content'].first['text']['value']

    # Cleanup
    begin
      @client.files.delete(id: file_id)
    rescue StandardError
      nil
    end
    begin
      @client.assistants.delete(id: assistant['id'])
    rescue StandardError
      nil
    end

    response
  rescue Faraday::BadRequestError => e
    raise e if Rails.env.development?
    error = e.response.dig(:body, 'error')
    Rails.logger.error "OpenAI API Error: #{error['message']}"
    { error: error['message'] }.to_json
  rescue StandardError => e
    raise e if Rails.env.development?
    Rails.logger.error "OpenAI API Error: #{e.message}"
    { error: e.message }.to_json
  ensure
    temp_file&.close
    temp_file&.unlink
  end

  def parse_ai_response(response)
    return { error: 'No response from AI' } if response.blank?

    # Remove markdown code blocks if present
    json_content = response.gsub(/^```json\n/, '').gsub(/\n```$/, '')

    JSON.parse(json_content, symbolize_names: true)
  rescue JSON::ParserError => e
    Rails.logger.error "JSON Parse Error: #{e.message}"
    { error: 'Failed to parse AI response', raw: response }
  end
end
