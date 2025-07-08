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




