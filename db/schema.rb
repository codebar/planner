# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_24_130000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "dietary_restriction_enum", ["vegan", "vegetarian", "pescetarian", "halal", "gluten_free", "dairy_free", "other"]

  create_table "activities", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "key"
    t.bigint "owner_id"
    t.string "owner_type"
    t.text "parameters"
    t.bigint "recipient_id"
    t.string "recipient_type"
    t.bigint "trackable_id"
    t.string "trackable_type"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["owner_type", "owner_id"], name: "index_activities_on_owner_type_and_owner_id"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient_type_and_recipient_id"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable_type_and_trackable_id"
  end

  create_table "addresses", id: :serial, force: :cascade do |t|
    t.string "city"
    t.datetime "created_at", precision: nil
    t.text "directions"
    t.string "flat"
    t.string "latitude"
    t.string "longitude"
    t.string "postal_code"
    t.integer "sponsor_id"
    t.string "street"
    t.datetime "updated_at", precision: nil
  end

  create_table "announcements", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "created_by_id"
    t.datetime "expires_at", precision: nil
    t.text "message"
    t.datetime "updated_at", precision: nil
    t.index ["created_by_id"], name: "index_announcements_on_created_by_id"
  end

  create_table "attendance_warnings", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "member_id"
    t.integer "sent_by_id"
    t.datetime "updated_at", precision: nil
    t.index ["member_id"], name: "index_attendance_warnings_on_member_id"
    t.index ["sent_by_id"], name: "index_attendance_warnings_on_sent_by_id"
  end

  create_table "auth_services", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "member_id"
    t.string "provider"
    t.string "uid"
    t.datetime "updated_at", precision: nil
    t.index ["member_id"], name: "index_auth_services_on_member_id"
  end

  create_table "bans", id: :serial, force: :cascade do |t|
    t.integer "added_by_id"
    t.datetime "created_at", precision: nil
    t.datetime "expires_at", precision: nil
    t.text "explanation"
    t.integer "member_id"
    t.text "note"
    t.boolean "permanent", default: false
    t.string "reason"
    t.datetime "updated_at", precision: nil
    t.index ["added_by_id"], name: "index_bans_on_added_by_id"
    t.index ["member_id"], name: "index_bans_on_member_id"
  end

  create_table "chapters", id: :serial, force: :cascade do |t|
    t.boolean "active", default: true
    t.string "city"
    t.datetime "created_at", precision: nil
    t.text "description"
    t.string "email"
    t.string "image"
    t.string "name"
    t.string "slug"
    t.string "time_zone", default: "London", null: false
    t.datetime "updated_at", precision: nil
  end

  create_table "chapters_events", id: :serial, force: :cascade do |t|
    t.integer "chapter_id"
    t.integer "event_id"
    t.index ["chapter_id"], name: "index_chapters_events_on_chapter_id"
    t.index ["event_id"], name: "index_chapters_events_on_event_id"
  end

  create_table "chapters_meetings", id: :serial, force: :cascade do |t|
    t.integer "chapter_id"
    t.integer "meeting_id"
    t.index ["chapter_id"], name: "index_chapters_meetings_on_chapter_id"
    t.index ["meeting_id"], name: "index_chapters_meetings_on_meeting_id"
  end

  create_table "contacts", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "email"
    t.boolean "mailing_list_consent", default: false
    t.string "name"
    t.integer "sponsor_id"
    t.string "surname"
    t.string "token", null: false
    t.datetime "updated_at", precision: nil
    t.index ["email", "sponsor_id"], name: "index_contacts_on_email_and_sponsor_id", unique: true
    t.index ["sponsor_id"], name: "index_contacts_on_sponsor_id"
  end

  create_table "course_invitations", id: :serial, force: :cascade do |t|
    t.boolean "attended"
    t.boolean "attending"
    t.integer "course_id"
    t.datetime "created_at", precision: nil
    t.integer "member_id"
    t.text "note"
    t.string "token"
    t.datetime "updated_at", precision: nil
    t.index ["course_id"], name: "index_course_invitations_on_course_id"
    t.index ["member_id"], name: "index_course_invitations_on_member_id"
  end

  create_table "course_tutors", id: :serial, force: :cascade do |t|
    t.integer "course_id"
    t.datetime "created_at", precision: nil
    t.integer "tutor_id"
    t.datetime "updated_at", precision: nil
    t.index ["course_id"], name: "index_course_tutors_on_course_id"
    t.index ["tutor_id"], name: "index_course_tutors_on_tutor_id"
  end

  create_table "courses", id: :serial, force: :cascade do |t|
    t.integer "chapter_id"
    t.datetime "created_at", precision: nil
    t.datetime "date_and_time", precision: nil
    t.text "description"
    t.datetime "ends_at", precision: nil
    t.integer "seats", default: 0
    t.string "short_description"
    t.string "slug"
    t.integer "sponsor_id"
    t.string "ticket_url"
    t.string "title"
    t.integer "tutor_id"
    t.datetime "updated_at", precision: nil
    t.string "url"
    t.index ["chapter_id"], name: "index_courses_on_chapter_id"
    t.index ["sponsor_id"], name: "index_courses_on_sponsor_id"
    t.index ["tutor_id"], name: "index_courses_on_tutor_id"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "locked_at", precision: nil
    t.string "locked_by"
    t.integer "priority", default: 0, null: false
    t.string "queue"
    t.datetime "run_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "eligibility_inquiries", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "member_id"
    t.integer "sent_by_id"
    t.datetime "updated_at", precision: nil
    t.index ["member_id"], name: "index_eligibility_inquiries_on_member_id"
    t.index ["sent_by_id"], name: "index_eligibility_inquiries_on_sent_by_id"
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.boolean "announce_only"
    t.string "audience"
    t.text "coach_description"
    t.string "coach_questionnaire"
    t.integer "coach_spaces"
    t.boolean "confirmation_required", default: false
    t.datetime "created_at", precision: nil
    t.datetime "date_and_time", precision: nil
    t.text "description"
    t.boolean "display_coaches"
    t.boolean "display_students"
    t.string "email"
    t.datetime "ends_at", precision: nil
    t.string "external_url"
    t.string "info"
    t.boolean "invitable", default: false
    t.string "name"
    t.text "schedule"
    t.boolean "show_faq"
    t.string "slug"
    t.string "student_questionnaire"
    t.integer "student_spaces"
    t.boolean "surveys_required", default: false
    t.string "time_zone", default: "London", null: false
    t.string "tito_url"
    t.datetime "updated_at", precision: nil
    t.string "url"
    t.integer "venue_id"
    t.boolean "virtual", default: false, null: false
    t.index ["date_and_time"], name: "index_events_on_date_and_time"
    t.index ["slug"], name: "index_events_on_slug", unique: true
    t.index ["venue_id"], name: "index_events_on_venue_id"
  end

  create_table "feedback_requests", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "member_id"
    t.boolean "submited"
    t.string "token"
    t.datetime "updated_at", precision: nil
    t.integer "workshop_id"
    t.index ["member_id"], name: "index_feedback_requests_on_member_id"
    t.index ["workshop_id"], name: "index_feedback_requests_on_workshop_id"
  end

  create_table "feedbacks", id: :serial, force: :cascade do |t|
    t.integer "coach_id"
    t.datetime "created_at", precision: nil
    t.integer "rating"
    t.text "request"
    t.text "suggestions"
    t.integer "tutorial_id"
    t.datetime "updated_at", precision: nil
    t.integer "workshop_id"
    t.index ["coach_id"], name: "index_feedbacks_on_coach_id"
    t.index ["tutorial_id"], name: "index_feedbacks_on_tutorial_id"
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "group_announcements", id: :serial, force: :cascade do |t|
    t.integer "announcement_id"
    t.datetime "created_at", precision: nil
    t.integer "group_id"
    t.datetime "updated_at", precision: nil
    t.index ["announcement_id"], name: "index_group_announcements_on_announcement_id"
    t.index ["group_id"], name: "index_group_announcements_on_group_id"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.integer "chapter_id"
    t.datetime "created_at", precision: nil
    t.text "description"
    t.string "mailing_list_id"
    t.string "name"
    t.datetime "updated_at", precision: nil
    t.index ["chapter_id"], name: "index_groups_on_chapter_id"
  end

  create_table "invitations", id: :serial, force: :cascade do |t|
    t.boolean "attending"
    t.datetime "created_at", precision: nil
    t.integer "event_id"
    t.integer "member_id"
    t.text "note"
    t.string "role"
    t.string "token"
    t.datetime "updated_at", precision: nil
    t.boolean "verified"
    t.integer "verified_by_id"
    t.index ["event_id", "attending"], name: "index_invitations_event_attending"
    t.index ["event_id"], name: "index_invitations_on_event_id"
    t.index ["member_id", "attending"], name: "index_invitations_member_attending"
    t.index ["member_id"], name: "index_invitations_on_member_id"
    t.index ["verified_by_id"], name: "index_invitations_on_verified_by_id"
  end

  create_table "jobs", id: :serial, force: :cascade do |t|
    t.boolean "approved", default: false
    t.integer "approved_by_id"
    t.string "company"
    t.string "company_address"
    t.string "company_postcode"
    t.string "company_website"
    t.datetime "created_at", precision: nil
    t.integer "created_by_id"
    t.text "description"
    t.string "email"
    t.datetime "expiry_date", precision: nil
    t.string "link_to_job"
    t.string "location"
    t.datetime "published_on", precision: nil
    t.boolean "remote"
    t.integer "salary"
    t.string "slug"
    t.integer "status", default: 0
    t.boolean "submitted", default: false
    t.string "title"
    t.datetime "updated_at", precision: nil
    t.index ["created_by_id"], name: "index_jobs_on_created_by_id"
  end

  create_table "meeting_invitations", id: :serial, force: :cascade do |t|
    t.boolean "attended", default: false
    t.boolean "attending"
    t.datetime "created_at", precision: nil
    t.integer "meeting_id"
    t.integer "member_id"
    t.text "note"
    t.string "role"
    t.string "token"
    t.datetime "updated_at", precision: nil
    t.index ["meeting_id", "attending"], name: "index_meeting_invitations_meeting_attending"
    t.index ["meeting_id"], name: "index_meeting_invitations_on_meeting_id"
    t.index ["member_id", "attending"], name: "index_meeting_invitations_member_attending"
    t.index ["member_id"], name: "index_meeting_invitations_on_member_id"
  end

  create_table "meeting_talks", id: :serial, force: :cascade do |t|
    t.text "abstract"
    t.datetime "created_at", precision: nil
    t.string "description"
    t.integer "meeting_id"
    t.integer "speaker_id"
    t.string "title"
    t.datetime "updated_at", precision: nil
    t.index ["meeting_id"], name: "index_meeting_talks_on_meeting_id"
    t.index ["speaker_id"], name: "index_meeting_talks_on_speaker_id"
  end

  create_table "meetings", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "date_and_time", precision: nil
    t.text "description"
    t.datetime "ends_at", precision: nil
    t.boolean "invitable"
    t.boolean "invites_sent", default: false
    t.string "name"
    t.string "slug"
    t.integer "spaces"
    t.integer "sponsor_id"
    t.datetime "updated_at", precision: nil
    t.integer "venue_id"
    t.index ["slug"], name: "index_meetings_on_slug", unique: true
    t.index ["venue_id"], name: "index_meetings_on_venue_id"
  end

  create_table "member_email_deliveries", id: :serial, force: :cascade do |t|
    t.text "bcc", default: [], array: true
    t.text "body"
    t.text "cc", default: [], array: true
    t.datetime "created_at", null: false
    t.bigint "member_id"
    t.string "member_type"
    t.text "subject"
    t.text "to", default: [], array: true
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_member_email_deliveries_on_member_id"
  end

  create_table "member_notes", id: :serial, force: :cascade do |t|
    t.integer "author_id"
    t.datetime "created_at", precision: nil
    t.integer "member_id"
    t.text "note"
    t.datetime "updated_at", precision: nil
    t.index ["author_id"], name: "index_member_notes_on_author_id"
    t.index ["member_id"], name: "index_member_notes_on_member_id"
  end

  create_table "members", id: :serial, force: :cascade do |t|
    t.string "about_you"
    t.datetime "accepted_toc_at", precision: nil
    t.boolean "can_log_in", default: false, null: false
    t.datetime "created_at", precision: nil
    t.enum "dietary_restrictions", default: [], array: true, enum_type: "dietary_restriction_enum"
    t.string "email"
    t.integer "how_you_found_us"
    t.string "how_you_found_us_other_reason"
    t.string "mobile"
    t.string "name"
    t.datetime "opt_in_newsletter_at", precision: nil
    t.string "other_dietary_restrictions"
    t.string "pronouns"
    t.boolean "received_coach_welcome_email", default: false
    t.boolean "received_student_welcome_email", default: false
    t.string "surname"
    t.boolean "unsubscribed"
    t.datetime "updated_at", precision: nil
    t.index ["email"], name: "index_members_on_email", unique: true
  end

  create_table "members_permissions", id: false, force: :cascade do |t|
    t.integer "member_id"
    t.integer "permission_id"
    t.index ["member_id", "permission_id"], name: "index_members_permissions_on_member_id_and_permission_id"
  end

  create_table "members_roles", id: false, force: :cascade do |t|
    t.integer "member_id"
    t.integer "role_id"
    t.index ["member_id", "role_id"], name: "index_members_roles_on_member_id_and_role_id"
    t.index ["member_id"], name: "index_members_roles_on_member_id"
  end

  create_table "permissions", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "name"
    t.integer "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", precision: nil
    t.index ["name", "resource_type", "resource_id"], name: "index_permissions_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_permissions_on_name"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "description"
    t.string "name"
    t.datetime "updated_at", precision: nil
  end

  create_table "sponsors", id: :serial, force: :cascade do |t|
    t.text "accessibility_info"
    t.string "avatar"
    t.datetime "created_at", precision: nil
    t.text "description"
    t.string "image_cache"
    t.integer "level", default: 1, null: false
    t.string "name"
    t.integer "number_of_coaches"
    t.integer "seats", default: 15
    t.datetime "updated_at", precision: nil
    t.string "website"
  end

  create_table "sponsorships", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "event_id"
    t.string "level"
    t.integer "sponsor_id"
    t.datetime "updated_at", precision: nil
    t.index ["event_id"], name: "index_sponsorships_on_event_id"
    t.index ["sponsor_id"], name: "index_sponsorships_on_sponsor_id"
  end

  create_table "subscriptions", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "group_id"
    t.integer "member_id"
    t.datetime "updated_at", precision: nil
    t.index ["group_id"], name: "index_subscriptions_on_group_id"
    t.index ["member_id"], name: "index_subscriptions_on_member_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "testimonials", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "member_id"
    t.text "text"
    t.datetime "updated_at", precision: nil
    t.index ["member_id"], name: "index_testimonials_on_member_id"
  end

  create_table "tutorials", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "description"
    t.string "title"
    t.datetime "updated_at", precision: nil
    t.string "url"
    t.integer "workshop_id"
    t.index ["workshop_id"], name: "index_tutorials_on_workshop_id"
  end

  create_table "waiting_lists", id: :serial, force: :cascade do |t|
    t.boolean "auto_rsvp", default: true
    t.datetime "created_at", precision: nil
    t.integer "invitation_id"
    t.datetime "updated_at", precision: nil
    t.index ["invitation_id"], name: "index_waiting_lists_on_invitation_id", unique: true
  end

  create_table "workshop_invitations", id: :serial, force: :cascade do |t|
    t.boolean "attended"
    t.boolean "attending"
    t.boolean "automated_rsvp"
    t.datetime "created_at", precision: nil
    t.integer "last_overridden_by_id"
    t.integer "member_id"
    t.text "note"
    t.datetime "reminded_at", precision: nil
    t.string "role"
    t.datetime "rsvp_time", precision: nil
    t.string "token"
    t.text "tutorial"
    t.datetime "updated_at", precision: nil
    t.integer "workshop_id"
    t.index ["member_id", "attending"], name: "index_workshop_invitations_member_attending"
    t.index ["member_id"], name: "index_workshop_invitations_on_member_id"
    t.index ["token"], name: "index_workshop_invitations_on_token", unique: true
    t.index ["workshop_id", "attending"], name: "index_workshop_invitations_workshop_attending"
    t.index ["workshop_id"], name: "index_workshop_invitations_on_workshop_id"
  end

  create_table "workshop_sponsors", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.boolean "host", default: false
    t.integer "sponsor_id"
    t.datetime "updated_at", precision: nil
    t.integer "workshop_id"
    t.index ["sponsor_id"], name: "index_workshop_sponsors_on_sponsor_id"
    t.index ["workshop_id", "host"], name: "index_workshop_sponsors_on_workshop_id_and_host"
    t.index ["workshop_id"], name: "index_workshop_sponsors_on_workshop_id"
  end

  create_table "workshops", id: :serial, force: :cascade do |t|
    t.integer "chapter_id"
    t.integer "coach_spaces", default: 0
    t.datetime "created_at", precision: nil
    t.datetime "date_and_time", precision: nil
    t.text "description"
    t.datetime "ends_at", precision: nil
    t.boolean "invitable", default: true
    t.datetime "rsvp_closes_at", precision: nil
    t.datetime "rsvp_opens_at", precision: nil
    t.string "sign_up_url"
    t.string "slack_channel"
    t.string "slack_channel_link"
    t.integer "student_spaces", default: 0
    t.string "title"
    t.datetime "updated_at", precision: nil
    t.boolean "virtual", default: false
    t.index ["chapter_id"], name: "index_workshops_on_chapter_id"
    t.index ["date_and_time"], name: "index_workshops_on_date_and_time"
  end

  add_foreign_key "member_email_deliveries", "members"
end
