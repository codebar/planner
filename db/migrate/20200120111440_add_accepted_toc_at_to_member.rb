class AddAcceptedTocAtToMember < ActiveRecord::Migration[4.2]
  def change
    add_column :members, :accepted_toc_at, :datetime, default: nil
  end
end
