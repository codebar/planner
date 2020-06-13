class AddAcceptedTocAtToMember < ActiveRecord::Migration
  def change
    add_column :members, :accepted_toc_at, :datetime, default: nil
  end
end
