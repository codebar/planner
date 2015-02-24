class AddInviteNoteToSessions < ActiveRecord::Migration
  def change
    add_column :sessions, :invite_note, :text
  end
end
