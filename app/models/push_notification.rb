# == Schema Information
#
# Table name: push_notifications
#
#  id             :bigint(8)        not null, primary key
#  device_hash    :string
#  response       :integer          default("success")
#  error_response :text
#  push_payload   :json
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  os             :string
#  app_version    :string
#

class PushNotification < ApplicationRecord
  enum response: [:success, :unavailable, :device_unregistered, :unknown]
end
