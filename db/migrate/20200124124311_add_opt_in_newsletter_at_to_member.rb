class AddOptInNewsletterAtToMember < ActiveRecord::Migration
  def change
    add_column :members, :opt_in_newsletter_at, :datetime, default: nil
  end
end
