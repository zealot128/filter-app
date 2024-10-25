class Source::FindLogosJob < ApplicationJob
  def self.find_bad_or_missing
    Source.visible.find_each do |source|
      if source.logo.blank? or !source.logo.exists?
        perform_later(source.id)
        next
      end

      dimension = Paperclip::Geometry.from_file(source.logo).width
      if dimension < 60
        perform_later(source.id)
      end
    end
  end

  def perform(source_id)
    source = Source.find(source_id)
    LogoFinder.new(source).run
  end
end
