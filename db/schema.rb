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

ActiveRecord::Schema.define(version: 20131029210620) do

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

  create_table "invitations", force: true do |t|
    t.integer  "sessions_id"
    t.integer  "member_id"
    t.boolean  "attending"
    t.boolean  "attended"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
  end

  add_index "invitations", ["member_id"], name: "index_invitations_on_member_id"
  add_index "invitations", ["sessions_id"], name: "index_invitations_on_sessions_id"
  add_index "invitations", ["token"], name: "index_invitations_on_token", unique: true

  create_table "members", force: true do |t|
    t.string   "name"
    t.string   "surname"
    t.string   "email"
    t.string   "twitter"
    t.string   "about_you"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "unsubscribed"
  end

  create_table "members_roles", id: false, force: true do |t|
    t.integer "member_id"
    t.integer "role_id"
  end

  add_index "members_roles", ["member_id", "role_id"], name: "index_members_roles_on_member_id_and_role_id"
  add_index "members_roles", ["member_id"], name: "index_members_roles_on_member_id"

  create_table "roles", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "date_and_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "seats",         default: 15
  end

end
