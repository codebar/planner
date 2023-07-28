class AddSlackChannelAndSlackChannelLinkToWorkshop < ActiveRecord::Migration[4.2]
  def change
    add_column :workshops, :slack_channel, :string
    add_column :workshops, :slack_channel_link, :string
  end
end
