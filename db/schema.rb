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

ActiveRecord::Schema.define(version: 20181021014646) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.index ["created_by_id"], name: "index_announcements_on_created_by_id", using: :btree
  end

  create_table "attendance_warnings", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "sent_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["member_id"], name: "index_attendance_warnings_on_member_id", using: :btree
    t.index ["sent_by_id"], name: "index_attendance_warnings_on_sent_by_id", using: :btree
  end

  create_table "auth_services", force: :cascade do |t|
    t.integer  "member_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["member_id"], name: "index_auth_services_on_member_id", using: :btree
  end

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
    t.index ["added_by_id"], name: "index_bans_on_added_by_id", using: :btree
    t.index ["member_id"], name: "index_bans_on_member_id", using: :btree
  end

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
    t.index ["chapter_id"], name: "index_chapters_events_on_chapter_id", using: :btree
    t.index ["event_id"], name: "index_chapters_events_on_event_id", using: :btree
  end

  create_table "chapters_meetings", force: :cascade do |t|
    t.integer "chapter_id"
    t.integer "meeting_id"
    t.index ["chapter_id"], name: "index_chapters_meetings_on_chapter_id", using: :btree
    t.index ["meeting_id"], name: "index_chapters_meetings_on_meeting_id", using: :btree
  end

  create_table "contacts", force: :cascade do |t|
    t.integer  "sponsor_id"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["member_id"], name: "index_contacts_on_member_id", using: :btree
    t.index ["sponsor_id"], name: "index_contacts_on_sponsor_id", using: :btree
  end

  create_table "course_invitations", force: :cascade do |t|
    t.integer  "course_id"
    t.integer  "member_id"
    t.boolean  "attending"
    t.boolean  "attended"
    t.text     "note"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["course_id"], name: "index_course_invitations_on_course_id", using: :btree
    t.index ["member_id"], name: "index_course_invitations_on_member_id", using: :btree
  end

  create_table "course_tutors", force: :cascade do |t|
    t.integer  "course_id"
    t.integer  "tutor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["course_id"], name: "index_course_tutors_on_course_id", using: :btree
    t.index ["tutor_id"], name: "index_course_tutors_on_tutor_id", using: :btree
  end

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
    t.index ["chapter_id"], name: "index_courses_on_chapter_id", using: :btree
    t.index ["sponsor_id"], name: "index_courses_on_sponsor_id", using: :btree
    t.index ["tutor_id"], name: "index_courses_on_tutor_id", using: :btree
  end

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
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "eligibility_inquiries", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "sent_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["member_id"], name: "index_eligibility_inquiries_on_member_id", using: :btree
    t.index ["sent_by_id"], name: "index_eligibility_inquiries_on_sent_by_id", using: :btree
  end

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
    t.index ["slug"], name: "index_events_on_slug", unique: true, using: :btree
    t.index ["venue_id"], name: "index_events_on_venue_id", using: :btree
  end

  create_table "feedback_requests", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "workshop_id"
    t.string   "token"
    t.boolean  "submited"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["member_id"], name: "index_feedback_requests_on_member_id", using: :btree
    t.index ["workshop_id"], name: "index_feedback_requests_on_workshop_id", using: :btree
  end

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "tutorial_id"
    t.text     "request"
    t.integer  "coach_id"
    t.text     "suggestions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating"
    t.integer  "workshop_id"
    t.index ["coach_id"], name: "index_feedbacks_on_coach_id", using: :btree
    t.index ["tutorial_id"], name: "index_feedbacks_on_tutorial_id", using: :btree
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree
  end

  create_table "group_announcements", force: :cascade do |t|
    t.integer  "announcement_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["announcement_id"], name: "index_group_announcements_on_announcement_id", using: :btree
    t.index ["group_id"], name: "index_group_announcements_on_group_id", using: :btree
  end

  create_table "groups", force: :cascade do |t|
    t.integer  "chapter_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mailing_list_id"
    t.index ["chapter_id"], name: "index_groups_on_chapter_id", using: :btree
  end

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
    t.index ["event_id"], name: "index_invitations_on_event_id", using: :btree
    t.index ["member_id"], name: "index_invitations_on_member_id", using: :btree
    t.index ["verified_by_id"], name: "index_invitations_on_verified_by_id", using: :btree
  end

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
    t.index ["created_by_id"], name: "index_jobs_on_created_by_id", using: :btree
  end

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
    t.index ["meeting_id"], name: "index_meeting_invitations_on_meeting_id", using: :btree
    t.index ["member_id"], name: "index_meeting_invitations_on_member_id", using: :btree
  end

  create_table "meeting_talks", force: :cascade do |t|
    t.integer  "meeting_id"
    t.string   "title"
    t.string   "description"
    t.text     "abstract"
    t.integer  "speaker_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["meeting_id"], name: "index_meeting_talks_on_meeting_id", using: :btree
    t.index ["speaker_id"], name: "index_meeting_talks_on_speaker_id", using: :btree
  end

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
    t.index ["slug"], name: "index_meetings_on_slug", unique: true, using: :btree
    t.index ["venue_id"], name: "index_meetings_on_venue_id", using: :btree
  end

  create_table "member_contacts", force: :cascade do |t|
    t.integer  "sponsor_id"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "member_notes", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "author_id"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_id"], name: "index_member_notes_on_author_id", using: :btree
    t.index ["member_id"], name: "index_member_notes_on_member_id", using: :btree
  end

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
  end

  create_table "members_permissions", id: false, force: :cascade do |t|
    t.integer "member_id"
    t.integer "permission_id"
    t.index ["member_id", "permission_id"], name: "index_members_permissions_on_member_id_and_permission_id", using: :btree
  end

  create_table "members_roles", id: false, force: :cascade do |t|
    t.integer "member_id"
    t.integer "role_id"
    t.index ["member_id", "role_id"], name: "index_members_roles_on_member_id_and_role_id", using: :btree
    t.index ["member_id"], name: "index_members_roles_on_member_id", using: :btree
  end

  create_table "permissions", force: :cascade do |t|
    t.string   "name"
    t.string   "resource_type"
    t.integer  "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_permissions_on_name_and_resource_type_and_resource_id", using: :btree
    t.index ["name"], name: "index_permissions_on_name", using: :btree
  end

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
    t.string   "email"
    t.string   "contact_first_name"
    t.string   "contact_surname"
    t.text     "accessibility_info"
    t.integer  "level",              default: 1,  null: false
  end

  create_table "sponsorships", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "sponsor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_id"], name: "index_sponsorships_on_event_id", using: :btree
    t.index ["sponsor_id"], name: "index_sponsorships_on_sponsor_id", using: :btree
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["group_id"], name: "index_subscriptions_on_group_id", using: :btree
    t.index ["member_id"], name: "index_subscriptions_on_member_id", using: :btree
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.string   "taggable_type"
    t.integer  "taggable_id"
    t.string   "tagger_type"
    t.integer  "tagger_id"
    t.string   "context",       limit: 128
    t.datetime "created_at"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  end

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true, using: :btree
  end

  create_table "testimonials", force: :cascade do |t|
    t.integer  "member_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["member_id"], name: "index_testimonials_on_member_id", using: :btree
  end

  create_table "tutorials", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.integer  "workshop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["workshop_id"], name: "index_tutorials_on_workshop_id", using: :btree
  end

  create_table "waiting_lists", force: :cascade do |t|
    t.integer  "invitation_id"
    t.boolean  "auto_rsvp",     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["invitation_id"], name: "index_waiting_lists_on_invitation_id", using: :btree
  end

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
    t.index ["member_id"], name: "index_workshop_invitations_on_member_id", using: :btree
    t.index ["token"], name: "index_workshop_invitations_on_token", unique: true, using: :btree
    t.index ["workshop_id"], name: "index_workshop_invitations_on_workshop_id", using: :btree
  end

  create_table "workshop_sponsors", force: :cascade do |t|
    t.integer  "sponsor_id"
    t.integer  "workshop_id"
    t.boolean  "host",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["sponsor_id"], name: "index_workshop_sponsors_on_sponsor_id", using: :btree
    t.index ["workshop_id"], name: "index_workshop_sponsors_on_workshop_id", using: :btree
  end

  create_table "workshops", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "date_and_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "invitable",      default: true
    t.string   "sign_up_url"
    t.integer  "chapter_id"
    t.datetime "rsvp_closes_at"
    t.datetime "rsvp_opens_at"
    t.index ["chapter_id"], name: "index_workshops_on_chapter_id", using: :btree
  end

end
