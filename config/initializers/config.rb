if Rails.env.test?
  Rails.application.config.after_initialize do
    Setting.read_yaml
  end
end
