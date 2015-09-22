class DuplicateKiller
  attr_reader :source
  def initialize(source)
    @source = source
  end

  def run
    dups = source.news_items.group("regexp_replace(url, 'https?:', '')").having('count(*) > 1').select('array_agg(id) as ids').map(&:ids)
    dups.each do |group|
      nis = NewsItem.where(id: group).order('absolute_score desc').pluck(:id).to_a
      nis.shift
      NewsItem.where(id: nis).delete_all
    end
  end
end
