Fabricator(:source) do
  name 'pludoni news'
  type 'FeedSource'
  url { sequence(:url) { |i| "http://www.pludoni.de/#{i}/news.rss" } }
  value 1
  language 'german'
  multiplicator 1
end

Fabricator(:news_item) do
  source
  title ' Open-Sour­ce-Tech­no­lo­gi­en bei pludo­ni '
  teaser 'Bei der Software-Entwicklung in unserer Firma setzen wir auf verschiedene Open-Source Sprachen, Bibliotheken, Frameworks und Bibliotheken. Einige dieser exzellenten Tools möchte ich hier mal vorstellen und unsere Beweggründe für die Wahl anführen.'
  published_at '2018-02-15 16:14:00 CET'
  retweets 0
  guid '123123'
  absolute_score 10
  word_length 100
  plaintext { |a| a[:teaser] }
  url 'http://www.pludoni.de/news/6/open-source-technologien-bei-pludoni'

  after_create { rescore! }
end

Fabricator(:category) do
  name 'Studie'
  keywords 'Survey,studien,studie,umfrage,empirisch,forschungsbericht'
end

Fabricator(:user) do
  email { 'info@filter.de' }
  password { 'password123' }
  password_confirmation { |a| a[:password] }
  role 'sources_admin'
end

Fabricator(:admin, from: :user) do
  role 'admin'
  email 'admin@filter.de'
end

Fabricator(:mail_subscription) do
  gender 'male'
  interval 'weekly'
  categories {
    [Fabricate(:category).id]
  }
  email 'info@example.com'
  status 'confirmed'
  first_name 'John'
  last_name 'M'
  company 'FOOBAR'
  limit 50
end
