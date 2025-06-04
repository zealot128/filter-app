module SQLite3Configuration
  private

  def configure_connection
    super

    if @config[:retries]
      retries = self.class.type_cast_config_to_integer(@config[:retries])
      raw_connection.busy_handler do |count|
        (count <= retries).tap { |result| sleep count * 0.001 if result }
      end
    end
  end
end

if Rails.version.to_s['8.0.0']
  raise 'This patch is not needed for Rails 8.0.0 and above'
end

ActiveSupport.on_load :active_record_sqlite3adapter do
  prepend(SQLite3Configuration)
end
