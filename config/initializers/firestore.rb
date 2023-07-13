# ENV['GOOGLE_CLOUD_SUPPRESS_RUBY_WARNINGS'] = 'true'
#
# if File.exist?('config/firebase.json')
#   require 'fcm'
#   require "google-cloud-firestore"
#   require "google/cloud/firestore"
#   Google::Cloud::Firestore.configure do |config|
#     config.project_id  = Rails.application.secrets.firebase_project_id
#     config.credentials = "./config/firebase.json"
#   end
# end
