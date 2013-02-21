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

ActiveRecord::Schema.define(:version => 20130221135912) do

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
  end

  add_index "news_items", ["guid"], :name => "index_news_items_on_guid"
  add_index "news_items", ["source_id"], :name => "index_news_items_on_source_id"

  create_table "sources", :force => true do |t|
    t.string   "type"
    t.string   "url"
    t.string   "name"
    t.integer  "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sources", ["type"], :name => "index_sources_on_type"

end
