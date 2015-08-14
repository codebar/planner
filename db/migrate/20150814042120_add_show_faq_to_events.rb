class AddShowFaqToEvents < ActiveRecord::Migration
  def change
    add_column :events, :show_faq, :boolean
  end
end
