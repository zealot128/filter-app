# include PoltergeistHelper
module PoltergeistHelper
  extend ActiveSupport::Concern
  included do
    require 'capybara/poltergeist'
    Capybara.javascript_driver = :poltergeist
    Baseapp::Application.config.action_dispatch.show_exceptions = true
    WebMock.allow_net_connect!
  end

  # render screenshot of current page to /screenshot.jpg
  def screenshot(page)
    page.driver.render(Rails.root.join("public/screenshot.jpg").to_s)
  end

  # skip any confirm: "Really delete?"
  def skip_confirm(page)
    page.evaluate_script('window.confirm = function() { return true; }')
  end
end

