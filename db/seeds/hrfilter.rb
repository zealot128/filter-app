# to regenerate:
# FeedSource.where('value is not null').order('value::int desc').limit(30).map { |i| %[FeedSource.create(url: "#{i.url}", name: "#{i.name}", value: #{i.value}, full_text_selector: "#{i.full_text_selector}")] }
FeedSource.create(url: "https://www.empfehlungsbund.de/news.atom", name: "Empfehlungsbund Blog", value: 50, full_text_selector: ".post-body")
FeedSource.create(url: "http://leipzig-hrm-blog.blogspot.com/feeds/posts/default", name: "Leipziger HRM Blog", value: 20, full_text_selector: ".entry-content")
FeedSource.create(url: "http://www.iab.de/751/feed.aspx", name: "Institut für Arbeitsmarkt- und Berufsforschung (IAB)", value: 10, full_text_selector: ".articlecontent")
FeedSource.create(url: "http://www.ik-blog.de/feed/", name: "Führmann Kommunikation", value: 10, full_text_selector: ".article")
FeedSource.create(url: "https://www.leadership-insiders.de/feed/", name: "Leadership Insiders", value: 10, full_text_selector: ".post")
FeedSource.create(url: "http://blog.recrutainment.de/feed/", name: "Recrutainment Blog", value: 6, full_text_selector: ".entry-content")
FeedSource.create(url: "https://www.fachkraeftesicherer.de/hrfeed", name: "Familienfreund KG", value: 5, full_text_selector: ".post-body")
FeedSource.create(url: "https://www.dgfp.de/?type=9818", name: "Deutschen Gesellschaft zur Personalführung e.V.", value: 5, full_text_selector: ".article")
FeedSource.create(url: "http://www.ifm-bonn.org/index.php?id=5&type=100", name: "Institut für Mittelstandsforschung Bonn", value: 5, full_text_selector: ".bodytext")
FeedSource.create(url: "http://talential.com/feed/", name: "Talential-Blog zu Job, Karriere und Recruiting", value: 5, full_text_selector: ".entry-content")
FeedSource.create(url: "http://berufebilder.de/feed/", name: "BERUFEBILDER.DE - Best of HR", value: 5, full_text_selector: ".entry-content")
FeedSource.create(url: "https://www.hrperformance-online.de/news/?sRss=1", name: "HR Performance Online", value: 5, full_text_selector: ".blog--detail-box-content.block")
FeedSource.create(url: "http://www.wkdis.de/aktuelles/rssfeed.php?newscat=11", name: "Personalpraxis24.de", value: 5, full_text_selector: ".main_content")
FeedSource.create(url: "https://blog.iao.fraunhofer.de/category/mensch-und-arbeitswelt/feed/", name: "Fraunhofer IAO Blog", value: 5, full_text_selector: ".content-area")
FeedSource.create(url: "http://feeds.feedburner.com/OnlineRecruiting?format=xml", name: "Online-Recruiting.net - Der internationale E-Recruiting Trends Blog", value: 5, full_text_selector: ".entry-content")
FeedSource.create(url: "https://www.datenschutz-notizen.de/feed/atom/", name: "datenschutz notizen", value: 5, full_text_selector: ".post-content")
FeedSource.create(url: "http://feeds.soundcloud.com/users/soundcloud:users:337257940/sounds.rss", name: "personalmarketing2null", value: 5, full_text_selector: "article")
FeedSource.create(url: "http://hr4good.com/feed", name: "HR4Good", value: 5, full_text_selector: ".entry-content")
FeedSource.create(url: "http://feeds.feedburner.com/HRExaminer", name: "HR Examiner", value: 5, full_text_selector: ".textcontent")
FeedSource.create(url: "http://blog.metahr.de/feed/", name: "metaHR:", value: 5, full_text_selector: ".entry-content")
FeedSource.create(url: "http://www.hrpraxis.ch/feed", name: "hrpraxis.ch", value: 5, full_text_selector: ".entry-content")
FeedSource.create(url: "https://hashtaghr.blog/feed/", name: "Hashtag HR Blog", value: 5, full_text_selector: ".content")
FeedSource.create(url: "https://www.kompetenz-management.com/feed/", name: "Kompetenz- & Performancemanagement Blog", value: 5, full_text_selector: ".post")
FeedSource.create(url: "http://feeds.feedburner.com/MittelstandsBlog", name: "Mittelstandswiki", value: 5, full_text_selector: ".mw-content-text")
FeedSource.create(url: "http://personalmarketing2null.de/feed", name: "personalmarkting2null", value: 5, full_text_selector: "article .formatted")
FeedSource.create(url: "http://arbeitgebermarkenfreunde.de/feed/", name: "Mein Freund die Arbeitgebermarke", value: 5, full_text_selector: ".entry-content")
FeedSource.create(url: "https://efarbeitsrecht.net/feed/", name: "Expertenforum Arbeitsrecht", value: 5, full_text_selector: ".entry-content")
FeedSource.create(url: "http://www.controllerakademie.de/feed/", name: "CA Controller Akademie", value: 5, full_text_selector: ".entry-content")
FeedSource.create(url: "https://hrtrendinstitute.com/feed/", name: "HR Trend Institute", value: 3, full_text_selector: ".cb-entry-content")
FeedSource.create(url: "https://www.generation-silberhaar.de/feed/", name: "Demographie-Blog", value: 3, full_text_selector: ".post-content")

Source.find_each do |s|
  Source::FindLogosJob.set(wait: 1.minute).perform_later(s.id)
end

# to regenerate
# Category.all.map { |i| %[Category.create!(name: "#{i.name}", keywords: "#{i.keywords}", hash_tag: "#{i.hash_tag}")] }
Category.create!(name: "Personalmarketing", keywords: "Stellenanzeigen,Kandidaten,Fachkräftemangel,Jobbörse,Bewerbermanagement,talentpool,Karriereseite,job board,Stellenausschreibung,Matching,Recruiting,Stellenanzeige,Anschreiben,Bewerbungsunterlagen,Stellenbörse,kanaleo,kanaleo-analyse", hash_tag: "Personalmarketing")
Category.create!(name: "Personen", keywords: "Interview,personaler,manager,Aufsichtsratsvorsitzender,vorstand,personalie,HR Pros,hr leader", hash_tag: "Personen")
Category.create!(name: "Bildung", keywords: "weiterbildung,hochschule,Universität,ausbildung,mobile learning,online education,fortbildung,qualifikation,e-learning,fachhochschule,berufsakademie,berufsausbildung,innerbetriebliche ausbildung,fernstudium,fernuniversität", hash_tag: "Bildung")
Category.create!(name: "Social-Media", keywords: "facebook,xing,twitter,linkedin,fanpage,Social Networks,Spotify,social media,youtube,infografik,infographic", hash_tag: "Socialmedia")
Category.create!(name: "Karriere", keywords: "Lebenslauf,Anschreiben,Bewerbungsgespräch,Karriereplanung,Bewerber,karriereplanung,Karriereleiter,Beförderung,chef,degradierung,entlassung,gehaltserhöhung,Körpersprache,mentoren,mentor,Jobinterview,", hash_tag: "Karriere")
Category.create!(name: "Personalentwicklung", keywords: "Personalentwicklung,Personalentwickler,Beurteilungsgespräch,Mitarbeitergespräch,Fortbildung,Employee Empowerment,EFQM,Mitarbeiter entwickeln,Entwicklungsprogramm,Lernmanagementsystem,e-Learning,eLearning", hash_tag: "Personalentwicklung")
Category.create!(name: "Gehalt", keywords: "Gehalt,Bezahlung,equal pay,einkommen,vergütung,Verdienst,Variabler Anteil,Lohn,Entlohnung,jobwert,jobwert.info,Gehaltsbenchmark,Gehaltsvergleich,Benefit,Benefitbenchmark,Benefitvergleich", hash_tag: "Gehalt")
Category.create!(name: "Aktive Personalsuche", keywords: "Headhunter,Personalvermittlung,Personalvermittler,Direktansprache,Headhunting,active sourcer,active sourcing", hash_tag: "activesourcing")
Category.create!(name: "Führung", keywords: "Führung,Leadership,Mitarbeitergespräch,führungsinstrument,führungskraft,führungskräfte,Entscheider,Verantwortung,verantwortliche,führungsstil", hash_tag: "fuehrung")
Category.create!(name: "Controlling", keywords: "Kapitalrendite,ROI, Return on Investment,Personalkosten,Excell,Diagramm,Kennzahlen,Kennzahlensystem,Budgetierung,Finanzplanung,Lohnbuchhaltung,Buchhaltung,", hash_tag: "controlling")
Category.create!(name: "Organisationsentwicklung", keywords: "New Work, Arbeit 4.0, Work-Life Balance, Arbeitswelt, Industrie 4.0, Unternehmensentwicklung, Hierarchien, Unternehmenskultur, Digitalisierung, Veränderungsmanagement,Organisationskultur,Führungskultur,Arbeitsgestaltung,unternehmenskultur,", hash_tag: "NewWork")
Category.create!(name: "Arbeitsmarktforschung", keywords: "Survey,studien,studie,umfrage,empirisch,forschungsbericht,IAB,arbeitsmarktbarometer,repräsentativ,repräsentative,institut,vergleichsstudie,auswertungsbericht,auswertung,IAO,fachkräftemarkt,arbeitsmarkt,berufsforschung,whitepaper,arbeitsmärkte,benchmark,umfrageteilnehmer,probant,", hash_tag: "Arbeitsmarktforschung")
Category.create!(name: "Employer-Branding", keywords: "Kununu,employer-branding,arbeitgebermarke,Mitarbeiterbindung,arbeitgeberbewertung,Personalmarketing,Empfehlungsmarketing, Faire-Karriere,Arbeitgebersiegel,arbeitgeberimage,unternehmensimage,benefits,top-arbeitgeber,", hash_tag: "Employer-Branding")
Category.create!(name: "Arbeitsrecht", keywords: "Gerichtsurteil,abmahnung,§,Paragraph,Anwalt,verklagen,gericht,Sozialversicherung,privacy,datenschutz,versteuerung,Landesgericht,Verfassungsgericht,Bundesgerichtshof,Strafrecht,Arbeitsrecht,Bundesministerium,Bundesfamilienministerin,Bundesfamilienminister,Datenschutzgrundverordung,DSGVO,Beschäftigungsdatenschutz,
Datenschutzgrundverordnung,Eingliederungsmanagement,BEM,Arbeitgeber,ISO/IEC 27552,Bewerbungsverfahren,Vorbeschäftigungsverbot,
Datenschutz-Grundverordnung,Mitarbeiterüberwachung,Datenrichtigkeit,", hash_tag: "Arbeitsrecht")


# to regenerate:
# Trends::Trend.all.map { |i| words = i.words.map { |w| %[Trends::Word.create!(word: "#{w.word}")]}; puts "words = [ #{words.join(', ')} ]"; puts %[Trends::Trend.create!(name: "#{i.name}", words: words)] }
words = [ Trends::Word.create!(word: "stack overflow"), Trends::Word.create!(word: "stackoverflow"), Trends::Word.create!(word: "recruiting stack overflow"), Trends::Word.create!(word: "entwicklerumfrage"), Trends::Word.create!(word: "overflow entwicklerumfrage") ]
Trends::Trend.create!(name: "stack overflow entwicklerumfrage", words: words)
words = [ Trends::Word.create!(word: "arbeitgebermarkenwert weiterbildung"), Trends::Word.create!(word: "berufsbegleitende weiterbildung"), Trends::Word.create!(word: "e-learning weiterbildung"), Trends::Word.create!(word: "personalentwicklung weiterbildung"), Trends::Word.create!(word: "weiterbildungskosten investition weiterbildung"), Trends::Word.create!(word: "fort- weiterbildung"), Trends::Word.create!(word: "förderung weiterbildung"), Trends::Word.create!(word: "budget weiterbildung"), Trends::Word.create!(word: "online-weiterbildung"), Trends::Word.create!(word: "mitarbeiterweiterbildung"), Trends::Word.create!(word: "digitalisierung arbeitsmarktes weiterbildung"), Trends::Word.create!(word: "bildungsprämie weiterbildung"), Trends::Word.create!(word: "rechtsfragen weiterbildung"), Trends::Word.create!(word: "prüfung weiterbildung"), Trends::Word.create!(word: "thesen digitalisierung weiterbildung"), Trends::Word.create!(word: "qualifizierungsmaßnahmen weiterbildung"), Trends::Word.create!(word: "arbeitszeit weiterbildung") ]
Trends::Trend.create!(name: "Weiterbildung", words: words)
words = [  ]
Trends::Trend.create!(name: "zukunft personal", words: words)
words = [ Trends::Word.create!(word: "algorithmen"), Trends::Word.create!(word: "künstliche intelligenz"), Trends::Word.create!(word: "technologie künstliche intelligenz"), Trends::Word.create!(word: "machine learning"), Trends::Word.create!(word: "chatbot"), Trends::Word.create!(word: "einsatz künstlicher intelligenz ki"), Trends::Word.create!(word: "künstlicher intelligenz ki"), Trends::Word.create!(word: "roboter"), Trends::Word.create!(word: "algorithmus"), Trends::Word.create!(word: "algorithmischer") ]
Trends::Trend.create!(name: "KI im Recruiting", words: words)
words = [ Trends::Word.create!(word: "google for jobs"), Trends::Word.create!(word: "for jobs google"), Trends::Word.create!(word: "gegen google"), Trends::Word.create!(word: "jobsuche google"), Trends::Word.create!(word: "google for jobs google") ]
Trends::Trend.create!(name: "Google for Jobs", words: words)
words = [ Trends::Word.create!(word: "kündigung wegen sexueller"), Trends::Word.create!(word: "kündigung wegen sexueller belästigung"), Trends::Word.create!(word: "kündigung wegen fremdenfeindlicher"), Trends::Word.create!(word: "rechtmäßige kündigung wegen fremdenfeindlicher"), Trends::Word.create!(word: "equal pay day"), Trends::Word.create!(word: "gender pay gap"), Trends::Word.create!(word: "gender"), Trends::Word.create!(word: "vergütung gender"), Trends::Word.create!(word: "entgelttransparenz gender"), Trends::Word.create!(word: "gender-pay"), Trends::Word.create!(word: "fair pay"), Trends::Word.create!(word: "gender pay"), Trends::Word.create!(word: "equal pay"), Trends::Word.create!(word: "entgelttransparenz fair pay"), Trends::Word.create!(word: "entgelttransparenz gender pay"), Trends::Word.create!(word: "gender gap"), Trends::Word.create!(word: "gender-pay gap"), Trends::Word.create!(word: "pay gap"), Trends::Word.create!(word: "wegen ostdeutscher"), Trends::Word.create!(word: "ostdeutscher herkunft"), Trends::Word.create!(word: "sexuelle belästigung arbeitsplatz erlebt"), Trends::Word.create!(word: "diskriminierung arbeitsplatz erlebt"), Trends::Word.create!(word: "vergangenen jahren sexuelle belästigung"), Trends::Word.create!(word: "jahren sexuelle belästigung arbeitsplatz"), Trends::Word.create!(word: "sexuelle belästigung"), Trends::Word.create!(word: "wegen ostdeutscher herkunft"), Trends::Word.create!(word: "diskriminierung arbeitsplatz") ]
Trends::Trend.create!(name: "Betriebliche Gleichberechtigung ", words: words)
words = [ Trends::Word.create!(word: "new work"), Trends::Word.create!(word: "better work"), Trends::Word.create!(word: "future work"), Trends::Word.create!(word: "vereinbarkeit familie beruf") ]
Trends::Trend.create!(name: "New Work", words: words)
words = [ Trends::Word.create!(word: "neuen hr-trends"), Trends::Word.create!(word: "hr-trends"), Trends::Word.create!(word: "hr-trends 2020") ]
Trends::Trend.create!(name: "Aktuelle HR Trends", words: words)
words = [ Trends::Word.create!(word: "recht einsicht digitale personalakten"), Trends::Word.create!(word: "arbeitgeber haftet"), Trends::Word.create!(word: "gemäß 87 abs"), Trends::Word.create!(word: "personalabteilung kein kündigungsgrund"), Trends::Word.create!(word: "auffassung bag"), Trends::Word.create!(word: "freistellungsphase altersteilzeit"), Trends::Word.create!(word: "arbeitsgericht braunschweig"), Trends::Word.create!(word: "vw kündigungsrecht gegen"), Trends::Word.create!(word: "missbrauch kundendaten rechtfertigt kündigung"), Trends::Word.create!(word: "arbeitsgericht siegburg"), Trends::Word.create!(word: "landesarbeitsgericht düsseldorf"), Trends::Word.create!(word: "lag düsseldorf"), Trends::Word.create!(word: "kritik personalabteilung kein kündigungsgrund") ]
Trends::Trend.create!(name: "Arbeitsrecht", words: words)
words = [ Trends::Word.create!(word: "janina kugel"), Trends::Word.create!(word: "bettina volkens") ]
Trends::Trend.create!(name: "Personen", words: words)
words = [ Trends::Word.create!(word: "stack overflow entwicklerumfrage"), Trends::Word.create!(word: "online recruiting studie"), Trends::Word.create!(word: "laut aktuellen studie"), Trends::Word.create!(word: "online recruiting studie 2019") ]
Trends::Trend.create!(name: "Arbeitsmarktforschung", words: words)
words = [ Trends::Word.create!(word: "zukunft personal europe"), Trends::Word.create!(word: "zukunftpersonal"), Trends::Word.create!(word: "zukunft-personal"), Trends::Word.create!(word: "messe zukunft personal"), Trends::Word.create!(word: "messe zukunft"), Trends::Word.create!(word: "zukunft personal"), Trends::Word.create!(word: "hr innovation day 2019"), Trends::Word.create!(word: "deutscher personalwirtschaftspreis"), Trends::Word.create!(word: "personalwirtschaftspreis") ]
Trends::Trend.create!(name: "HR Events", words: words)
words = [ Trends::Word.create!(word: "corona-krise trifft"), Trends::Word.create!(word: "coronakrise unternehmen"), Trends::Word.create!(word: "wegen coronavirus"), Trends::Word.create!(word: "arbeitsausfall wegen coronavirus"), Trends::Word.create!(word: "kurzarbeitergeld arbeitsausfall wegen coronavirus"), Trends::Word.create!(word: "corona-krise kurzfristige arbeitnehmerüberlassung"), Trends::Word.create!(word: "corona-krise kurzfristige arbeitnehmerüberlassung möglich"), Trends::Word.create!(word: "wegen corona-krise"), Trends::Word.create!(word: "während corona-krise"), Trends::Word.create!(word: "kununu corona"), Trends::Word.create!(word: "recruiting zeiten corona"), Trends::Word.create!(word: "auswirkungen corona"), Trends::Word.create!(word: "thema corona"), Trends::Word.create!(word: "zeit corona"), Trends::Word.create!(word: "während corona"), Trends::Word.create!(word: "gegen corona"), Trends::Word.create!(word: "trotz corona"), Trends::Word.create!(word: "wegen corona"), Trends::Word.create!(word: "zeiten corona") ]
Trends::Trend.create!(name: "Corona + Recruiting", words: words)


