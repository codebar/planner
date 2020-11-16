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

ActiveRecord::Schema.define(version: 20201120012812) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "addresses", force: :cascade do |t|
    t.string   "flat"
    t.string   "street"
    t.string   "postal_code"
    t.integer  "sponsor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "city"
    t.string   "latitude"
    t.string   "longitude"
    t.text     "directions"
  end

  create_table "announcements", force: :cascade do |t|
    t.datetime "expires_at"
    t.text     "message"
    t.integer  "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "announcements", ["created_by_id"], name: "index_announcements_on_created_by_id", using: :btree

  create_table "attendance_warnings", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "sent_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attendance_warnings", ["member_id"], name: "index_attendance_warnings_on_member_id", using: :btree
  add_index "attendance_warnings", ["sent_by_id"], name: "index_attendance_warnings_on_sent_by_id", using: :btree

  create_table "auth_services", force: :cascade do |t|
    t.integer  "member_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "auth_services", ["member_id"], name: "index_auth_services_on_member_id", using: :btree

  create_table "bans", force: :cascade do |t|
    t.integer  "member_id"
    t.datetime "expires_at"
    t.string   "reason"
    t.text     "note"
    t.integer  "added_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "permanent",   default: false
    t.text     "explanation"
  end

  add_index "bans", ["added_by_id"], name: "index_bans_on_added_by_id", using: :btree
  add_index "bans", ["member_id"], name: "index_bans_on_member_id", using: :btree

  create_table "chapters", force: :cascade do |t|
    t.string   "name"
    t.string   "city"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "twitter"
    t.string   "twitter_id"
    t.string   "slug"
    t.boolean  "active",      default: true
    t.string   "time_zone",   default: "London", null: false
    t.text     "description"
    t.string   "image"
  end

  create_table "chapters_events", force: :cascade do |t|
    t.integer "chapter_id"
    t.integer "event_id"
  end

  add_index "chapters_events", ["chapter_id"], name: "index_chapters_events_on_chapter_id", using: :btree
  add_index "chapters_events", ["event_id"], name: "index_chapters_events_on_event_id", using: :btree

  create_table "chapters_meetings", force: :cascade do |t|
    t.integer "chapter_id"
    t.integer "meeting_id"
  end

  add_index "chapters_meetings", ["chapter_id"], name: "index_chapters_meetings_on_chapter_id", using: :btree
  add_index "chapters_meetings", ["meeting_id"], name: "index_chapters_meetings_on_meeting_id", using: :btree

  create_table "contacts", force: :cascade do |t|
    t.integer  "sponsor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "surname"
    t.string   "email"
    t.boolean  "mailing_list_consent", default: false
<<<<<<< HEAD
    t.string   "token",                                null: false
=======
    t.string   "token", null: false
>>>>>>> bootstrap organsiers and avatar shared partial
  end

  add_index "contacts", ["email", "sponsor_id"], name: "index_contacts_on_email_and_sponsor_id", unique: true, using: :btree
  add_index "contacts", ["sponsor_id"], name: "index_contacts_on_sponsor_id", using: :btree

  create_table "course_invitations", force: :cascade do |t|
    t.integer  "course_id"
    t.integer  "member_id"
    t.boolean  "attending"
    t.boolean  "attended"
    t.text     "note"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_invitations", ["course_id"], name: "index_course_invitations_on_course_id", using: :btree
  add_index "course_invitations", ["member_id"], name: "index_course_invitations_on_member_id", using: :btree

  create_table "course_tutors", force: :cascade do |t|
    t.integer  "course_id"
    t.integer  "tutor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_tutors", ["course_id"], name: "index_course_tutors_on_course_id", using: :btree
  add_index "course_tutors", ["tutor_id"], name: "index_course_tutors_on_tutor_id", using: :btree

  create_table "courses", force: :cascade do |t|
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
    t.integer  "sponsor_id"
    t.string   "ticket_url"
    t.integer  "chapter_id"
    t.datetime "ends_at"
  end

  add_index "courses", ["chapter_id"], name: "index_courses_on_chapter_id", using: :btree
  add_index "courses", ["sponsor_id"], name: "index_courses_on_sponsor_id", using: :btree
  add_index "courses", ["tutor_id"], name: "index_courses_on_tutor_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "eligibility_inquiries", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "sent_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "eligibility_inquiries", ["member_id"], name: "index_eligibility_inquiries_on_member_id", using: :btree
  add_index "eligibility_inquiries", ["sent_by_id"], name: "index_eligibility_inquiries_on_sent_by_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "date_and_time"
    t.datetime "ends_at"
    t.integer  "venue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.text     "schedule"
    t.integer  "coach_spaces"
    t.integer  "student_spaces"
    t.string   "coach_questionnaire"
    t.string   "student_questionnaire"
    t.text     "coach_description"
    t.string   "info"
    t.boolean  "announce_only"
    t.string   "url"
    t.string   "email"
    t.boolean  "invitable",             default: false
    t.string   "tito_url"
    t.boolean  "show_faq"
    t.boolean  "display_students"
    t.boolean  "display_coaches"
    t.string   "external_url"
    t.boolean  "confirmation_required", default: false
    t.boolean  "surveys_required",      default: false
    t.string   "audience"
  end

  add_index "events", ["slug"], name: "index_events_on_slug", unique: true, using: :btree
  add_index "events", ["venue_id"], name: "index_events_on_venue_id", using: :btree

  create_table "feedback_requests", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "workshop_id"
    t.string   "token"
    t.boolean  "submited"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feedback_requests", ["member_id"], name: "index_feedback_requests_on_member_id", using: :btree
  add_index "feedback_requests", ["workshop_id"], name: "index_feedback_requests_on_workshop_id", using: :btree

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "tutorial_id"
    t.text     "request"
    t.integer  "coach_id"
    t.text     "suggestions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating"
    t.integer  "workshop_id"
  end

  add_index "feedbacks", ["coach_id"], name: "index_feedbacks_on_coach_id", using: :btree
  add_index "feedbacks", ["tutorial_id"], name: "index_feedbacks_on_tutorial_id", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "group_announcements", force: :cascade do |t|
    t.integer  "announcement_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_announcements", ["announcement_id"], name: "index_group_announcements_on_announcement_id", using: :btree
  add_index "group_announcements", ["group_id"], name: "index_group_announcements_on_group_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.integer  "chapter_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mailing_list_id"
  end

  add_index "groups", ["chapter_id"], name: "index_groups_on_chapter_id", using: :btree

  create_table "invitations", force: :cascade do |t|
    t.integer  "event_id"
    t.boolean  "attending"
    t.integer  "member_id"
    t.string   "role"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.boolean  "verified"
    t.integer  "verified_by_id"
  end

  add_index "invitations", ["event_id"], name: "index_invitations_on_event_id", using: :btree
  add_index "invitations", ["member_id"], name: "index_invitations_on_member_id", using: :btree
  add_index "invitations", ["verified_by_id"], name: "index_invitations_on_verified_by_id", using: :btree

  create_table "jobs", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.string   "location"
    t.datetime "expiry_date"
    t.string   "email"
    t.string   "link_to_job"
    t.integer  "created_by_id"
    t.boolean  "approved",         default: false
    t.boolean  "submitted",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "company"
    t.integer  "approved_by_id"
    t.string   "company_website"
    t.string   "company_address"
    t.string   "company_postcode"
    t.datetime "published_on"
    t.boolean  "remote"
    t.integer  "salary"
    t.string   "slug"
    t.integer  "status",           default: 0
  end

  add_index "jobs", ["created_by_id"], name: "index_jobs_on_created_by_id", using: :btree

  create_table "meeting_invitations", force: :cascade do |t|
    t.integer  "meeting_id"
    t.boolean  "attending"
    t.integer  "member_id"
    t.string   "role"
    t.text     "note"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "attended",   default: false
  end

  add_index "meeting_invitations", ["meeting_id"], name: "index_meeting_invitations_on_meeting_id", using: :btree
  add_index "meeting_invitations", ["member_id"], name: "index_meeting_invitations_on_member_id", using: :btree

  create_table "meeting_talks", force: :cascade do |t|
    t.integer  "meeting_id"
    t.string   "title"
    t.string   "description"
    t.text     "abstract"
    t.integer  "speaker_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "meeting_talks", ["meeting_id"], name: "index_meeting_talks_on_meeting_id", using: :btree
  add_index "meeting_talks", ["speaker_id"], name: "index_meeting_talks_on_speaker_id", using: :btree

  create_table "meetings", force: :cascade do |t|
    t.datetime "date_and_time"
    t.integer  "venue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "description"
    t.string   "slug"
    t.boolean  "invitable"
    t.integer  "spaces"
    t.integer  "sponsor_id"
    t.boolean  "invites_sent",  default: false
    t.datetime "ends_at"
  end

  add_index "meetings", ["slug"], name: "index_meetings_on_slug", unique: true, using: :btree
  add_index "meetings", ["venue_id"], name: "index_meetings_on_venue_id", using: :btree

  create_table "member_notes", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "author_id"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "member_notes", ["author_id"], name: "index_member_notes_on_author_id", using: :btree
  add_index "member_notes", ["member_id"], name: "index_member_notes_on_member_id", using: :btree

  create_table "members", force: :cascade do |t|
    t.string   "name"
    t.string   "surname"
    t.string   "email"
    t.string   "twitter"
    t.string   "about_you"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "unsubscribed"
    t.boolean  "can_log_in",                     default: false, null: false
    t.string   "mobile"
    t.boolean  "received_coach_welcome_email",   default: false
    t.boolean  "received_student_welcome_email", default: false
    t.string   "pronouns"
    t.datetime "accepted_toc_at"
    t.datetime "opt_in_newsletter_at"
  end

  add_index "members", ["email"], name: "index_members_on_email", unique: true, using: :btree

  create_table "members_permissions", id: false, force: :cascade do |t|
    t.integer "member_id"
    t.integer "permission_id"
  end

  add_index "members_permissions", ["member_id", "permission_id"], name: "index_members_permissions_on_member_id_and_permission_id", using: :btree

  create_table "members_roles", id: false, force: :cascade do |t|
    t.integer "member_id"
    t.integer "role_id"
  end

  add_index "members_roles", ["member_id", "role_id"], name: "index_members_roles_on_member_id_and_role_id", using: :btree
  add_index "members_roles", ["member_id"], name: "index_members_roles_on_member_id", using: :btree

  create_table "permissions", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["name", "resource_type", "resource_id"], name: "index_permissions_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "permissions", ["name"], name: "index_permissions_on_name", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sponsors", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar"
    t.string   "website"
    t.integer  "seats",              default: 15
    t.string   "image_cache"
    t.integer  "number_of_coaches"
    t.text     "accessibility_info"
    t.integer  "level",              default: 1,  null: false
  end

  create_table "sponsorships", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "sponsor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "level"
  end

  add_index "sponsorships", ["event_id"], name: "index_sponsorships_on_event_id", using: :btree
  add_index "sponsorships", ["sponsor_id"], name: "index_sponsorships_on_sponsor_id", using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscriptions", ["group_id"], name: "index_subscriptions_on_group_id", using: :btree
  add_index "subscriptions", ["member_id"], name: "index_subscriptions_on_member_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "testimonials", force: :cascade do |t|
    t.integer  "member_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "testimonials", ["member_id"], name: "index_testimonials_on_member_id", using: :btree

  create_table "tutorials", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.integer  "workshop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tutorials", ["workshop_id"], name: "index_tutorials_on_workshop_id", using: :btree

  create_table "waiting_lists", force: :cascade do |t|
    t.integer  "invitation_id"
    t.boolean  "auto_rsvp",     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "waiting_lists", ["invitation_id"], name: "index_waiting_lists_on_invitation_id", using: :btree

  create_table "workshop_invitations", force: :cascade do |t|
    t.integer  "workshop_id"
    t.integer  "member_id"
    t.boolean  "attending"
    t.boolean  "attended"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "role"
    t.datetime "reminded_at"
    t.datetime "rsvp_time"
    t.boolean  "automated_rsvp"
    t.text     "tutorial"
  end

  add_index "workshop_invitations", ["member_id"], name: "index_workshop_invitations_on_member_id", using: :btree
  add_index "workshop_invitations", ["token"], name: "index_workshop_invitations_on_token", unique: true, using: :btree
  add_index "workshop_invitations", ["workshop_id"], name: "index_workshop_invitations_on_workshop_id", using: :btree

  create_table "workshop_sponsors", force: :cascade do |t|
    t.integer  "sponsor_id"
    t.integer  "workshop_id"
    t.boolean  "host",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workshop_sponsors", ["sponsor_id"], name: "index_workshop_sponsors_on_sponsor_id", using: :btree
  add_index "workshop_sponsors", ["workshop_id"], name: "index_workshop_sponsors_on_workshop_id", using: :btree

  create_table "workshops", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "date_and_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "invitable",          default: true
    t.string   "sign_up_url"
    t.integer  "chapter_id"
    t.datetime "rsvp_closes_at"
    t.datetime "rsvp_opens_at"
    t.datetime "ends_at"
    t.boolean  "virtual",            default: false
    t.integer  "student_spaces",     default: 0
    t.integer  "coach_spaces",       default: 0
    t.string   "slack_channel"
    t.string   "slack_channel_link"
  end

  add_index "workshops", ["chapter_id"], name: "index_workshops_on_chapter_id", using: :btree

end
