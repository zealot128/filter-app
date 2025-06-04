RSpec.describe Resources::MailSubscriptions, type: :request do
  describe '/api/v1/mail_subscriptions' do
    let(:api_key) { Rails.application.credentials.secret_api_key }

    specify 'check if email exists' do
      get '/api/v1/mail_subscriptions.json', params: {
        api_key:,
        email: "test@test.com"
      }
      expect(response.status).to be == 404
    end

    specify 'create subscription' do
      Category.create!(name: 'Recruiting', keywords: 'Headhunter')
      post '/api/v1/mail_subscriptions.json', params: {
        api_key:,
        email: "test@test.com",
        categories: ['recruiting'],
        first_name: "Max",
        last_name: "Mustermann",
        gender: 'male',
        academic_title: "",
        company: "pludoni GmbH",
        interval: 'weekly',
        limit: 25
      }
      expect(response.status).to be == 201
      expect(MailSubscription.count).to be == 1

      get '/api/v1/mail_subscriptions.json', params: {
        api_key:,
        email: "test@test.com"
      }
      expect(response.status).to be == 200
      expect(json.mail_subscription).to be_present
      expect(json.mail_subscription['first_name']).to be == 'Max'
    end
  end

  def json
    j = JSON.parse(response.body)
    if j.is_a?(Hash)
      Hashie::Mash.new(j)
    else
      j
    end
  end
end
