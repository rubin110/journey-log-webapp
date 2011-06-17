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

ActiveRecord::Schema.define(:version => 20110615000002) do

  create_table "checkins", :primary_key => "checkin_id", :force => true do |t|
    t.string   "runner_id"
    t.integer  "checkpoint_id"
    t.datetime "checkin_time"
    t.string   "device_id"
    t.string   "user_agent"
    t.float    "lng"
    t.float    "lat"
    t.boolean  "is_valid",      :default => true
  end

  add_index "checkins", ["checkin_time", "checkpoint_id", "is_valid"], :name => "index_checkins_on_checkin_time_and_checkpoint_id_and_is_valid"
  add_index "checkins", ["checkpoint_id", "checkin_time", "is_valid"], :name => "index_checkins_on_checkpoint_id_and_checkin_time_and_is_valid"
  add_index "checkins", ["checkpoint_id"], :name => "index_checkins_on_checkpoint_id"
  add_index "checkins", ["lat"], :name => "index_checkins_on_lat"
  add_index "checkins", ["lng"], :name => "index_checkins_on_lng"
  add_index "checkins", ["runner_id", "checkpoint_id"], :name => "index_checkins_on_runner_id_and_checkpoint_id", :unique => true

  create_table "checkpoints", :id => false, :force => true do |t|
    t.integer "checkpoint_id"
    t.string  "checkpoint_name"
    t.float   "checkpoint_loc_lat"
    t.float   "checkpoint_loc_long"
    t.boolean "is_mobile",           :default => false
    t.boolean "is_bonus",            :default => false
    t.integer "checkpoint_position"
  end

  add_index "checkpoints", ["checkpoint_id"], :name => "index_checkpoints_on_checkpoint_id"
  add_index "checkpoints", ["checkpoint_loc_lat"], :name => "index_checkpoints_on_checkpoint_loc_lat"
  add_index "checkpoints", ["checkpoint_loc_long"], :name => "index_checkpoints_on_checkpoint_loc_long"
  add_index "checkpoints", ["checkpoint_position"], :name => "index_checkpoints_on_checkpoint_position"
  add_index "checkpoints", ["is_mobile", "is_bonus"], :name => "index_checkpoints_on_is_mobile_and_is_bonus"

  create_table "runners", :id => false, :force => true do |t|
    t.string   "runner_id"
    t.string   "player_email"
    t.string   "player_name"
    t.boolean  "is_mugshot"
    t.datetime "time_of_mugshot"
    t.boolean  "is_registered"
    t.datetime "time_of_registration"
    t.boolean  "is_tagged"
  end

  add_index "runners", ["is_tagged"], :name => "index_runners_on_is_tagged"
  add_index "runners", ["runner_id"], :name => "index_runners_on_runner_id"

  create_table "tags", :primary_key => "tag_id", :force => true do |t|
    t.string   "runner_id"
    t.string   "tagger_id"
    t.datetime "tag_time"
    t.float    "loc_lat"
    t.float    "loc_long"
    t.string   "loc_addr"
    t.string   "device_id"
    t.string   "user_agent"
    t.string   "ip_address"
  end

  add_index "tags", ["loc_lat"], :name => "index_tags_on_loc_lat"
  add_index "tags", ["loc_long"], :name => "index_tags_on_loc_long"
  add_index "tags", ["runner_id", "tagger_id"], :name => "index_tags_on_runner_id_and_tagger_id", :unique => true
  add_index "tags", ["tag_id"], :name => "index_tags_on_tag_id"
  add_index "tags", ["tagger_id", "runner_id"], :name => "index_tags_on_tagger_id_and_runner_id"

end
