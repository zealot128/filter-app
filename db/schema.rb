# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131102124426) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.text     "keywords"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "categories_news_items", :id => false, :force => true do |t|
    t.integer "category_id"
    t.integer "news_item_id"
  end

  add_index "categories_news_items", ["category_id", "news_item_id"], :name => "categories_news_items_index", :unique => true

  create_table "news_items", :force => true do |t|
    t.string   "title"
    t.text     "teaser"
    t.string   "url"
    t.integer  "source_id"
    t.datetime "published_at"
    t.integer  "value"
    t.integer  "fb_likes"
    t.integer  "retweets"
    t.string   "guid"
    t.integer  "linkedin"
    t.integer  "xing"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "gplus"
    t.text     "full_text"
  end

  add_index "news_items", ["guid"], :name => "index_news_items_on_guid"
  add_index "news_items", ["published_at"], :name => "index_news_items_on_published_at"
  add_index "news_items", ["source_id"], :name => "index_news_items_on_source_id"
  add_index "news_items", ["value"], :name => "index_news_items_on_value"

  create_table "sources", :force => true do |t|
    t.string   "type"
    t.string   "url"
    t.string   "name"
    t.integer  "value"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "full_text_selector"
  end

  add_index "sources", ["type"], :name => "index_sources_on_type"

end
