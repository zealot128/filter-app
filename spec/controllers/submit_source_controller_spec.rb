describe SubmitSourceController do
  render_views

  specify 'form works' do
    get :new
    expect(response).to be_successful
  end

  specify 'successful form post delivers mail' do
    post :create, params: {
      submit_source: {
        url: 'http://www.example.com/url',
        email: 'info@example.com',
        comment: 'bla'
      }
    }

    expect(ActionMailer::Base.deliveries.count).to eq(1)
    mail = ActionMailer::Base.deliveries.first
    expect(mail.to).to eq([Setting.email])
  end
end
