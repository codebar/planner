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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131222160002) do

  create_table "addresses", force: true do |t|
    t.string   "flat"
    t.string   "street"
    t.string   "postal_code"
    t.integer  "sponsor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "auth_services", force: true do |t|
    t.integer  "member_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "auth_services", ["member_id"], name: "index_auth_services_on_member_id"

  create_table "course_invitations", force: true do |t|
    t.integer  "course_id"
    t.integer  "member_id"
    t.boolean  "attending"
    t.boolean  "attended"
    t.text     "note"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_invitations", ["course_id"], name: "index_course_invitations_on_course_id"
  add_index "course_invitations", ["member_id"], name: "index_course_invitations_on_member_id"

  create_table "courses", force: true do |t|
    t.string   "title"
    t.string   "short_description"
    t.text     "description"
    t.integer  "tutor_id"
    t.datetime "date_and_time"
    t.integer  "seats",             default: 0
    t.string   "slug"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feedbacks", force: true do |t|
    t.integer  "tutorial_id"
    t.text     "request"
    t.integer  "coach_id"
    t.text     "suggestions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.integer  "rating"
  end

  add_index "feedbacks", ["coach_id"], name: "index_feedbacks_on_coach_id"
  add_index "feedbacks", ["token"], name: "index_feedbacks_on_token", unique: true
  add_index "feedbacks", ["tutorial_id"], name: "index_feedbacks_on_tutorial_id"

  create_table "meeting_talks", force: true do |t|
    t.integer  "meeting_id"
    t.string   "title"
    t.string   "description"
    t.text     "abstract"
    t.integer  "speaker_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "meeting_talks", ["meeting_id"], name: "index_meeting_talks_on_meeting_id"

  create_table "meetings", force: true do |t|
    t.datetime "date_and_time"
    t.integer  "duration",      default: 120
    t.string   "lanyrd_url"
    t.integer  "venue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members", force: true do |t|
    t.string   "name"
    t.string   "surname"
    t.string   "email"
    t.string   "twitter"
    t.string   "about_you"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "unsubscribed"
    t.boolean  "can_log_in",   default: false, null: false
  end

  create_table "members_roles", id: false, force: true do |t|
    t.integer "member_id"
    t.integer "role_id"
  end

  add_index "members_roles", ["member_id", "role_id"], name: "index_members_roles_on_member_id_and_role_id"
  add_index "members_roles", ["member_id"], name: "index_members_roles_on_member_id"

  create_table "reminders", force: true do |t|
    t.string   "reminder_type"
    t.string   "reminder_id"
    t.datetime "date_and_time"
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "session_invitations", force: true do |t|
    t.integer  "sessions_id"
    t.integer  "member_id"
    t.boolean  "attending"
    t.boolean  "attended"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "role"
  end

  add_index "session_invitations", ["member_id"], name: "index_session_invitations_on_member_id"
  add_index "session_invitations", ["sessions_id"], name: "index_session_invitations_on_sessions_id"
  add_index "session_invitations", ["token"], name: "index_session_invitations_on_token", unique: true

  create_table "sessions", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "date_and_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sponsor_sessions", force: true do |t|
    t.integer  "sponsor_id"
    t.integer  "sessions_id"
    t.boolean  "host",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sponsor_sessions", ["sessions_id"], name: "index_sponsor_sessions_on_sessions_id"
  add_index "sponsor_sessions", ["sponsor_id"], name: "index_sponsor_sessions_on_sponsor_id"

  create_table "sponsors", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar"
    t.string   "website"
    t.integer  "seats",       default: 15
  end

  create_table "tutorials", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.integer  "sessions_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tutorials", ["sessions_id"], name: "index_tutorials_on_sessions_id"

end
