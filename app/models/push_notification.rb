class PushNotification < ApplicationRecord
  enum response: [:success, :unavailable, :device_unregistered, :unknown]
end
