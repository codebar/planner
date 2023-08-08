class AddOptInNewsletterAtToMember < ActiveRecord::Migration[4.2]
  def change
    add_column :members, :opt_in_newsletter_at, :datetime, default: nil
  end
end
