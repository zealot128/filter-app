class InitialImport
  def initialize(person_hash)
    @data = person_hash
  end

  def run
    ms = MailSubscription.where(email: @data[:email]).first_or_initialize
    ms.first_name ||= @data[:vorname]
    ms.last_name ||= @data[:nachname]
    ms.gender ||= @data[:anrede] == 'Herr' ? 'male' : 'female'
    ms.extended_member = true
    ms.confirmed ||= true
    ms.limit ||= 50
    if ms.persisted?
      ms.save validate: false
      send_mail(ms)
      puts "Already exists: #{@data[:email]}, extending"
    else
      ms.interval = 'monthly'
      ms.categories = categories
    end
    ms.save validate: false
    send_mail(ms)
  end

  def send_mail(ms)
    NewsletterMailer.initial_mail(ms).deliver_now
  end

  def categories
    Category.where('name not in (?)', ['Events', "Bewerbung", "Bildung", "Karriere"]).map(&:id)
  end
end

import = File.read('one-timers/import.tsv')

header = [:email,:anrede,:vorname,:nachname]
people = import.split("\n").map{|i| header.zip(i.split("\t")).to_h }
people.take(2).each do |person|
  InitialImport.new(person).run
end
