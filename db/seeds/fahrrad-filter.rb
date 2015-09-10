tuples = Nokogiri::XML.parse(open('db/seeds/TinyTinyRSS.opml')).search('outline[xmlUrl]').map{|i| [i['text'], i['xmlUrl']]}

tuples.each do |title, url|
  FeedSource.where(url: url).first_or_create!(url: url, name: title, value: 1, multiplicator: 1)
end

Source.where(name: 'Velohome').update_all type: PodcastSource


Category.create! name: 'Rennrad', keywords: 'Rennrad,Aero,Lenkerband,Carbon,Road bike,Radmarathon,Time Trial'
Category.create! name: 'MTB/ATB', keywords: 'MTB,ATB,Fat Bike,Crosscycle,Mountain Bike'

Category.create! name: 'E-Bikes', keywords: 'E-Bike,Pedelec,Akku,Strom,S-Klasse,Elektrofahrrad,Elektromofa,Elektroantrieb'

Category.create! name: 'Fixie', keywords: 'Fixie,Single-Speed,Hipster,Fixed Gear,Eingangrad'

Category.create! name: 'Gadget', keywords: 'Garmin,Strava,Schloss,Schlösser,Uvex,Fahrradbrille,Helm,Bekleidung,Trikot,Klickpedal,Schuhe'

Category.create! name: 'Touren', keywords: 'Radreise,Randonee,randonnée,Randonneur,Tour,Reise'

Category.create! name: 'Regional', keywords: 'Hamburg,Berlin,Köln,München,Stuttgart,Frankfurt,Wiesbaden,Rhein-Main,Hessen,Osnabrück'

