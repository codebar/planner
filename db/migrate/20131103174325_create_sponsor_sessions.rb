class CreateSponsorSessions < ActiveRecord::Migration
  def change
    create_table :sponsor_sessions do |t|
      t.belongs_to :sponsor, index: true
      t.belongs_to :sessions, index: true
      t.boolean :host, default: false
      t.timestamps
    end
  end
end
