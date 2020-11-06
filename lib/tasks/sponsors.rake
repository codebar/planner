namespace :sponsors do
  namespace :contacts do
    desc 'Migrates contact information from Sponsor model to Contact model'
    task migrate: :environment do
      sponsors = Sponsor.all
      sponsors.each do |sponsor|
        contact = sponsor.contacts.build
        contact.name = sponsor.contact_first_name
        contact.surname = sponsor.contact_surname
        contact.email = sponsor.email
        if contact.save
          sponsor.update(contact_first_name: nil, contact_surname: nil, email: nil)
          Rails.logger.info("Sponsor #{sponsor.name} contact details migrated")
        end
      end
    end
  end

  namespace :members do
    desc 'Creates Contact entries for Sponsor associated Members'
    task migrate_to_contacts: :environment do
      sponsors = Sponsor.all
      sponsors.each do |sponsor|
        member_contacts = sponsor.member_contacts
        member_contacts.each do |member_contact|
          contact = sponsor.contacts.build
          contact.name = member_contact.member.name
          contact.surname = member_contact.member.surname
          contact.email = member_contact.member.email
          if contact.save
            member_contact.delete
            Rails.logger.info("Sponsor #{sponsor.name} MemberContact #{member_contact.member.name} migrated to Contact")
          end
        end
      end
    end
  end
end
