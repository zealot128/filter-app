class Resources::MailSubscriptions < Grape::API
  include BaseAPI
  helpers do
    def authenticate!
      if params[:signed_request]
        crypt = ActiveSupport::MessageEncryptor.new(Rails.application.credentials.api_cors_key)
        crypt.rotate cipher: "aes-256-cbc"
        r = crypt.decrypt_and_verify(params[:signed_request])
        unless r
          render json: { error: "Unauthorized - Message verification error" }, status: :unauthorized
          return
        end
        new_params = JSON.parse(r)
        params.merge!(new_params)
        params.delete(:signed_request)
      elsif params[:api_key] != Rails.application.credentials.secret_api_key
        error!({ message: 'missing/wrong api key' }, 403)
      end
    end
  end

  before do
    authenticate!
  end

  namespace :mail_subscriptions do
    params do
      requires :email, type: String
    end
    get '/' do
      ms = MailSubscription.find_by(email: params[:email])
      if ms
        { mail_subscription: ms.as_json }
      else
        error!({ message: "Subscription not found" }, 404)
      end
    end

    params do
      requires :email, type: String
    end
    post '/' do
      ms = MailSubscription.new(params.slice('first_name', 'email', 'last_name', 'gender', 'academic_title', 'company', 'position', 'interval',
'limit'))
      if params[:categories]
        ms.categories = Category.where('name ilike any (array[:s]) or slug ilike any (array[:s])', s: params[:categories]).pluck(:id)
      end
      ms.categories = Category.pluck(:id) if ms.categories.blank?

      if ms.save
        SubscriptionMailer.confirmation_mail(ms).deliver_now
        { mail_subscription: ms.as_json }
      else
        error!({ message: "Validation Errors", errors: ms.errors.as_json }, 422)
      end
    end
  end
end
