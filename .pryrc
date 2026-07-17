# vim: ft=ruby
if ENV['RAILS_ENV'] == 'production' || ENV['RAILS_ENV'] == 'staging'
  Pry.config.history_file = '/backup/share/pry-history'
  # https://github.com/pry/pry/issues/493#issuecomment-71243789
  reset = "\001\e[0m\002"
  green = "\001\e[01;38;5;46m\002"
  red = "\001\e[01;31;5;202m\002"
  brightred = "\001\e[01;38;5;203m\002"
  grey = "\001\e[01;38;5;239m\002"
  # https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
  #                 38,5:COLORCODEm ->
  blue = "\001\e[01;38;5;142m\002"

  current_app = "#{green}#{ENV['USER']}#{reset}"
  rails_env = "#{red}#{ENV["RAILS_ENV"]}#{reset}"
  version = "#{brightred}#{ENV['RUBY_VERSION'].sub('ruby-', '')}#{reset}"
  if File.exist?("GIT_REVISION")
    sha = "#{blue}#{File.read("GIT_REVISION").strip[0..8]}#{reset}"
  elsif  ENV['KAMAL_CONTAINER_NAME']
    sha = "#{blue}#{ENV['KAMAL_CONTAINER_NAME']}#{reset}"
  end

  Pry.config.prompt = Pry::Prompt.new(
    "custom",
    "my custom prompt",
    [
      proc { |obj, nest_level, _| "#{current_app}@#{sha} #{rails_env}@#{version} #{grey}(#{obj})#{reset}> " }
    ]
  )
end
