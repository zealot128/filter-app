require 'lingua/stemmer'
class KeywordAnalyzer
  def run
    all_words = {}
    NewsItem.pluck("full_text").each do |item|
      Lingua.stemmer(strip_tags(item).downcase.split(/[,\.;\s]+/),
                     language: 'de').each do |word|
        all_words[word] ||= 0
        all_words[word] += 1
      end
    end
    all_words.sort_by{|a,b| -b}
  end

  def strip_tags(*args)
    ActionController::Base.helpers.strip_tags *args
  end
end
