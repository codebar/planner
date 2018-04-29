namespace :mailing_list do
  require 'services/mailing_list'

  desc 'Subscribe all group members to relevant mailing list'
  task update_all_subscribers: :environment do
    groups = Group.all

    groups.each do |group|
      mailing_list = MailingList.new(group.mailing_list_id)

      group.members.each do |member|
        puts mailing_list.subscribe(member.email, member.name, member.surname)
      end
    end
  end

  desc 'Subscribe group members to specified mailing lists'
  task :subscribe_group, %i[list_id group_id] => :environment do |t, args|
    raise 'You must specify both a list_id and a group_id' unless args_valid?(args)

    mailing_list = MailingList.new(args[:list_id])
    group = Group.find(args[:group_id])

    group.members.each do |member|
      mailing_list.subscribe(member.email, member.name, member.surname)
    end
  end
end

def args_valid?(args)
  args.key?(:list_id) && args.key?(:group_id)
end
