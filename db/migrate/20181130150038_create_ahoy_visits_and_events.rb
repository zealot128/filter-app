class CreateAhoyVisitsAndEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :ahoy_visits do |t|
      t.string "visit_token"
      t.string "visitor_token"
      t.string "ip"
      t.text "user_agent"
      t.text "referrer"
      t.string "referring_domain"
      t.text "landing_page"
      t.string "whois_hostname"
      t.string "recommended_username"
      t.boolean "used_search"
      t.boolean "used_job_site"
      t.string "browser"
      t.string "os"
      t.string "device_type"
      t.string "utm_source"
      t.string "utm_medium"
      t.string "utm_term"
      t.string "utm_content"
      t.string "utm_campaign"
      t.datetime "started_at"
      t.string "coworkr_code"
      t.boolean "synced", default: false
    end

    add_index :ahoy_visits, [:visit_token], unique: true

    create_table :ahoy_events do |t|
      t.references :visit

      t.string :name
      t.jsonb :properties
      t.timestamp :time
    end

    add_index :ahoy_events, [:name, :time]
    add_index :ahoy_events, "properties jsonb_path_ops", using: "gin"
  end
end
