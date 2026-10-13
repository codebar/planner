class DropJobsCoursesCourseTutorsAndCourseInvitationsTables < ActiveRecord::Migration[7.0]
  def up
    drop_table :course_tutors
    drop_table :course_invitations
    drop_table :courses
    drop_table :jobs
  end

  def down
    create_table :courses, id: :serial do |t|
      t.string :title
      t.string :short_description
      t.text :description
      t.integer :tutor_id
      t.datetime :date_and_time, precision: nil
      t.integer :seats, default: 0
      t.string :slug
      t.string :url
      t.datetime :created_at, precision: nil
      t.datetime :updated_at, precision: nil
      t.integer :sponsor_id
      t.string :ticket_url
      t.integer :chapter_id
      t.datetime :ends_at, precision: nil

      t.index :chapter_id, name: "index_courses_on_chapter_id"
      t.index :sponsor_id, name: "index_courses_on_sponsor_id"
      t.index :tutor_id, name: "index_courses_on_tutor_id"
    end

    create_table :course_tutors, id: :serial do |t|
      t.integer :course_id
      t.integer :tutor_id
      t.datetime :created_at, precision: nil
      t.datetime :updated_at, precision: nil

      t.index :course_id, name: "index_course_tutors_on_course_id"
      t.index :tutor_id, name: "index_course_tutors_on_tutor_id"
    end

    create_table :course_invitations, id: :serial do |t|
      t.integer :course_id
      t.integer :member_id
      t.boolean :attending
      t.boolean :attended
      t.text :note
      t.string :token
      t.datetime :created_at, precision: nil
      t.datetime :updated_at, precision: nil

      t.index :course_id, name: "index_course_invitations_on_course_id"
      t.index :member_id, name: "index_course_invitations_on_member_id"
    end

    create_table :jobs, id: :serial do |t|
      t.string :title
      t.text :description
      t.string :location
      t.datetime :expiry_date, precision: nil
      t.string :email
      t.string :link_to_job
      t.integer :created_by_id
      t.boolean :approved, default: false
      t.boolean :submitted, default: false
      t.datetime :created_at, precision: nil
      t.datetime :updated_at, precision: nil
      t.string :company
      t.integer :approved_by_id
      t.string :company_website
      t.string :company_address
      t.string :company_postcode
      t.datetime :published_on, precision: nil
      t.boolean :remote
      t.integer :salary
      t.string :slug
      t.integer :status, default: 0

      t.index :created_by_id, name: "index_jobs_on_created_by_id"
    end
  end
end
