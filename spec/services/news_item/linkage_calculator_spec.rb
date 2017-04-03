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

    expect(target.referenced_news.to_a).to eq([source])
    expect(source.referencing_news.to_a).to eq([target])

    # Multiple run idempotent
    NewsItem::LinkageCalculator.run(scope: NewsItem.all)

    expect(target.referenced_news.to_a).to eq([source])
    expect(source.referencing_news.to_a).to eq([target])
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

    _ni2 = source1.news_items.build.tap do |ni|
      ni.url = "http://www.empfehlungsbund.de/news/2"
      ni.guid = 2
      ni.save!
    end

    NewsItem::LinkageCalculator.run(scope: NewsItem.all)

    expect(ni1.referenced_news.to_a).to eq([])
  end

  it 'ignores relative urls' do
    ni1 = source1.news_items.build.tap do |ni|
      ni.full_text = <<-DOC
        Blab la <a href='/kontakt'>EB1</a>
        Blab la <a href='./kontakt'>EB2</a>
        Blab la <a href='kontakt'>EB3</a>
      DOC
      ni.url = "http://www.pludoni.de/kontakt"
      ni.save!
    end

    _ni2 = source2.news_items.build.tap do |ni|
      ni.url = "http://www.empfehlungsbund.de/kontakt"
      ni.guid = 2
      ni.save!
    end

    NewsItem::LinkageCalculator.run(scope: NewsItem.all)
    expect(ni1.referenced_news.to_a).to eq([])
  end
end
