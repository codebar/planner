require 'spec_helper'
RSpec.feature 'Managing workshop attendance', type: :feature do
  let(:coach) { Fabricate(:coach) }
  let(:student) { Fabricate(:student) }

  context '#workshop' do
    let(:workshop) { Fabricate(:workshop) }
    let(:workshop_auto_rsvp_in_past) { Fabricate(:workshop_auto_rsvp_in_past) }
    let(:workshop_auto_rsvp_in_future) { Fabricate(:workshop_auto_rsvp_in_future) }

    include_examples 'managing workshop attendance'
  end

  context '#virtual workshop' do
    let(:workshop) { Fabricate(:virtual_workshop) }
    let(:workshop_auto_rsvp_in_past) { Fabricate(:workshop_auto_rsvp_in_past) }
    let(:workshop_auto_rsvp_in_future) { Fabricate(:workshop_auto_rsvp_in_future) }

    include_examples 'managing workshop attendance'
  end
end
