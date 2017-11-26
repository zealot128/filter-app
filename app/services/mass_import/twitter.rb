module MassImport
  class Twitter
    # give text with @people lines
    def initialize(text)
      @accounts = text.split(/[\s\b()]+/).grep(/^@\w{3,}/)
    end

    def skip?(account)
      TwitterSource.where('url like ?', "%#{account.gsub('@', '')}%").exists?
    end

    def import_as(language: 'en', value: 1)
      @accounts.each do |account|
        next if skip?(account)
        tw = nil
        begin
          tw = TwitterSource.new(
            url: account,
            name: account,
            value: value,
            language: language
          )
          tw.save!
        rescue ::Twitter::Error::Forbidden, ::Twitter::Error::NotFound => e
          $stderr.puts e.inspect
          $stderr.puts account
          tw.destroy if tw && tw.persisted?
        end
      end
    end
  end
end
