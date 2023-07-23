class AddShowFaqToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :show_faq, :boolean
  end
end
