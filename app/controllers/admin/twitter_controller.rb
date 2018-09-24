class Admin::TwitterController < AdminController
  skip_before_action :verify_authenticity_token, only: [:create]

  def index
  end

  def create
    info = request.env['omniauth.auth'].info

    Setting.set('twitter_account', info.nickname)
    Setting.set('twitter_access_token', request.env['omniauth.auth'].credentials.token)
    Setting.set('twitter_access_secret', request.env['omniauth.auth'].credentials.secret)
    redirect_to '/admin/twitter', notice: "Verbindung erfolgreich"
  end

  def follow
    accounts = (Source.where.not(twitter_account: nil).pluck(:twitter_account) + TwitterSource.all.map(&:user_name)).map(&:downcase).uniq
    accounts.reject!(&:blank?)
    @new_follows = TwitterGateway.new.follow_all(accounts)
  end
end
