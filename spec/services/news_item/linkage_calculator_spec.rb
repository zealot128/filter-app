require 'spec_helper'

describe NewsItem::LinkageCalculator do
  let(:source1) { Source.create! url: 'http://www.pludoni.de/xml', name: '1' }
  let(:source2) { Source.create! url: 'http://www.empfehlungsbund.de/xml', name: '2' }

  it 'finds news item relationship via a href links - also ignores http/https' do
    source = source1.news_items.build.tap do |ni|
      ni.full_text = "Blab la <a href='http://www.empfehlungsbund.de/news/1'>EB1</a>"
      ni.save!
    end

    target = source2.news_items.build.tap do |ni|
      ni.url = "https://www.empfehlungsbund.de/news/1"
      ni.save!
    end

    NewsItem::LinkageCalculator.run(scope: NewsItem.all)

    target.referenced_news.to_a.should be == [ source ]
    source.referencing_news.to_a.should be == [ target ]

    # Multiple run idempotent
    NewsItem::LinkageCalculator.run(scope: NewsItem.all)

    target.referenced_news.to_a.should be == [ source ]
    source.referencing_news.to_a.should be == [ target ]
  end

  it 'ignores self referencing links' do
    ni1 = source1.news_items.build.tap do |ni|
      ni.full_text = <<-DOC
        Blab la <a href='http://www.empfehlungsbund.de/news/1'>EB1</a>
        Blab la <a href='http://www.empfehlungsbund.de/news/2'>EB2</a>
      DOC
      ni.url = "http://www.empfehlungsbund.de/news/1"
      ni.save!
    end

    ni2 = source1.news_items.build.tap do |ni|
      ni.url = "http://www.empfehlungsbund.de/news/2"
      ni.guid = 2
      ni.save!
    end

    NewsItem::LinkageCalculator.run(scope: NewsItem.all)

    ni1.referenced_news.to_a.should be == []
  end

end
