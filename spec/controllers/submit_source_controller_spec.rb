require 'spec_helper'

describe SubmitSourceController do
  render_views

  specify 'form works' do
    get :new
    response.should be_success
  end

  specify 'successful form post delivers mail' do
    post :create, submit_source: {
      url: 'http://www.example.com/url',
      email: 'info@example.com',
      comment: 'bla'
    }

    ActionMailer::Base.deliveries.count.should be == 1
    mail = ActionMailer::Base.deliveries.first
    mail.to.should be == [Setting.email]
  end
end
