RSpec.describe 'user invite' do
  include Devise::Test::IntegrationHelpers

  let(:admin) { Fabricate(:admin) }

  specify 'User invite' do
    sign_in admin
    post '/admin/users', params: {
      user: {
        email: 'newuser@example.com',
        role: 'sources_admin'
      }
    }
    expect(response).to be_redirect
    expect(User.count).to be == 2
    user = User.find_by(email: 'newuser@example.com')
    expect(user.role).to be == 'sources_admin'
    expect(ActionMailer::Base.deliveries.count).to be == 1

    url = Nokogiri::HTML.fragment(ActionMailer::Base.deliveries.last.html_part.decoded.to_s).at('a')['href']

    sign_out admin

    get url
    expect(response).to be_successful
    form = Nokogiri.parse(response.body).at('form')

    put form['action'], params: {
      user: {
        reset_password_token: form.at('input[name*=reset_password_token]')['value'],
        password: 'password1234',
        password_confirmation: 'password1234'
      }
    }
    expect(response).to be_redirect
    expect(user.reload.valid_password?('password1234')).to be == true
  end
end
