class Configuration
  include Singleton

  def configuration
    @configuration ||= Rails.application.config_for(:application)
  rescue RuntimeError
    @configuration ||= Rails.application.config_for('application.hrfilter')
  end

  def respond_to?(m, foobar="")
    configuration.has_key?(m.to_s)
  end

  def method_missing(m, *args, &block)
    if respond_to?(m)
      configuration[m.to_s]
    else
      super
    end
  end

  def self.method_missing(m, *args, &block)
    if instance.respond_to?(m)
      instance.send(m, *args, &block)
    else
      super
    end
  end
end
