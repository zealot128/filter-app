# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180924123850) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "fuzzystrmatch"
  enable_extension "pg_trgm"

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.text     "keywords"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "hash_tag"
  end

  create_table "categories_news_items", id: false, force: :cascade do |t|
    t.integer "category_id"
    t.integer "news_item_id"
    t.index ["category_id", "news_item_id"], name: "categories_news_items_index", unique: true, using: :btree
  end

  create_table "impressions", force: :cascade do |t|
    t.string   "impressionable_type"
    t.integer  "impressionable_id"
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "view_name"
    t.string   "request_hash"
    t.string   "ip_address"
    t.string   "session_hash"
    t.text     "message"
    t.text     "referrer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "params"
    t.index ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index", using: :btree
    t.index ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index", using: :btree
    t.index ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index", using: :btree
    t.index ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index", using: :btree
    t.index ["impressionable_type", "impressionable_id", "params"], name: "poly_params_request_index", using: :btree
    t.index ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index", using: :btree
    t.index ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index", using: :btree
    t.index ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index", using: :btree
    t.index ["user_id"], name: "index_impressions_on_user_id", using: :btree
  end

  create_table "linkages", force: :cascade do |t|
    t.integer  "from_id"
    t.integer  "to_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "different",  default: false
    t.index ["from_id"], name: "index_linkages_on_from_id", using: :btree
    t.index ["to_id"], name: "index_linkages_on_to_id", using: :btree
  end

  create_table "mail_subscription_histories", force: :cascade do |t|
    t.integer  "mail_subscription_id"
    t.integer  "news_items_in_mail"
    t.datetime "opened_at"
    t.string   "open_token"
    t.integer  "click_count",          default: 0
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["mail_subscription_id"], name: "index_mail_subscription_histories_on_mail_subscription_id", using: :btree
  end

  create_table "mail_subscriptions", force: :cascade do |t|
    t.text     "email"
    t.json     "preferences"
    t.string   "token"
    t.datetime "last_send_date"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "limit"
    t.integer  "gender"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "academic_title"
    t.string   "company"
    t.string   "position"
    t.boolean  "extended_member", default: false
    t.datetime "deleted_at"
    t.integer  "status",          default: 0
    t.index ["token"], name: "index_mail_subscriptions_on_token", unique: true, using: :btree
  end

  create_table "news_items", force: :cascade do |t|
    t.string   "title",                       limit: 255
    t.text     "teaser"
    t.string   "url",                         limit: 255
    t.integer  "source_id"
    t.datetime "published_at"
    t.integer  "value"
    t.integer  "fb_likes"
    t.integer  "retweets"
    t.string   "guid",                        limit: 255
    t.integer  "linkedin"
    t.integer  "xing"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "gplus"
    t.text     "full_text"
    t.integer  "word_length"
    t.text     "plaintext"
    t.tsvector "search_vector"
    t.integer  "incoming_link_count"
    t.float    "absolute_score"
    t.boolean  "blacklisted",                             default: false
    t.integer  "reddit"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "impression_count",                        default: 0
    t.string   "tweet_id"
    t.integer  "absolute_score_per_halflife"
    t.integer  "youtube_likes",                           default: 0
    t.integer  "youtube_views",                           default: 0
    t.index ["absolute_score", "published_at"], name: "index_news_items_on_absolute_score_and_published_at", using: :btree
    t.index ["absolute_score"], name: "index_news_items_on_absolute_score", using: :btree
    t.index ["guid"], name: "index_news_items_on_guid", using: :btree
    t.index ["published_at"], name: "index_news_items_on_published_at", using: :btree
    t.index ["search_vector"], name: "index_news_items_on_search_vector", using: :gin
    t.index ["source_id"], name: "index_news_items_on_source_id", using: :btree
    t.index ["value"], name: "index_news_items_on_value", using: :btree
  end

  create_table "settings", force: :cascade do |t|
    t.string "key"
    t.text   "value"
    t.index ["key"], name: "index_settings_on_key", unique: true, using: :btree
  end

  create_table "sources", force: :cascade do |t|
    t.string   "type",                          limit: 255
    t.string   "url",                           limit: 255
    t.string   "name",                          limit: 255
    t.integer  "value"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.string   "logo_file_name",                limit: 255
    t.string   "logo_content_type",             limit: 255
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "full_text_selector",            limit: 255
    t.boolean  "error"
    t.float    "multiplicator",                             default: 1.0
    t.boolean  "lsr_active",                                default: false
    t.boolean  "deactivated",                               default: false
    t.integer  "default_category_id"
    t.string   "lsr_confirmation_file_name"
    t.string   "lsr_confirmation_content_type"
    t.integer  "lsr_confirmation_file_size"
    t.datetime "lsr_confirmation_updated_at"
    t.string   "twitter_account"
    t.string   "language"
    t.text     "comment"
    t.text     "filter_rules"
    t.json     "statistics"
    t.index ["type"], name: "index_sources_on_type", using: :btree
  end

  add_foreign_key "mail_subscription_histories", "mail_subscriptions"
end
