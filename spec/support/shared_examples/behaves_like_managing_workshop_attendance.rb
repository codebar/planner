RSpec.shared_examples 'managing workshop attendance' do
  context 'a logged in member' do
    context '#upcoming workshop' do
      context 'via the workshop page' do
        let!(:tutorial) { Fabricate(:tutorial) }

        context 'with only student subscriptions' do
          before do
            login(student)
            visit workshop_path(workshop)
          end

          it 'can only RSVP as a student' do
            click_on 'Attend as a student'

            select tutorial.title, from: :workshop_invitation_tutorial
            click_on 'Attend'

            expect(page).to have_content('See you at the workshop')

            visit workshop_path(workshop)
            expect(page).to have_button('Manage your invitation')
          end

          it 'cannot RSVP as a coach' do
            expect(page).not_to have_content('Attend as a coach')
          end
        end

        context 'with only coach subscriptions' do
          before do
            login(coach)
            visit workshop_path(workshop)
          end

          it 'can only RSVP as a coach' do
            click_on 'Attend as a coach'
            click_on 'Attend'

            expect(page).to have_content('See you at the workshop')

            visit workshop_path(workshop)
            expect(page).to have_button('Manage your invitation')
          end

          it 'cannot RSVP as a student' do
            expect(page).not_to have_content('Attend as a student')
          end
        end

        context 'with both coach and student subscriptions' do
          before do
            kara = Fabricate(:student)
            coaches = Fabricate(:coaches)
            kara.groups << coaches
            login(kara)
            visit workshop_path(workshop)
          end

          it 'can get to the RSVP as a student page' do
            click_on 'Attend as a student'

            select tutorial.title, from: :workshop_invitation_tutorial
            click_on 'Attend'

            expect(page).to have_content('See you at the workshop')

            visit workshop_path(workshop)
            expect(page).to have_button('Manage your invitation')
          end

          it 'can get to the RSVP as a coach page' do
            click_on 'Attend as a coach'
            click_on 'Attend'

            expect(page).to have_content('See you at the workshop')

            visit workshop_path(workshop)
            expect(page).to have_button('Manage your invitation')
          end
        end

        context 'who has already RSVPed' do
          let(:student) { Fabricate(:student) }

          before do
            coaches = Fabricate(:coaches)
            student.groups << coaches
            login(student)
          end

          it 'can get back to their invitation page' do
            visit workshop_path(workshop)

            click_on 'Attend as a coach'
            click_on 'Attend'

            visit workshop_path(workshop)

            click_on 'Manage your invitation'
            expect(page).to have_content("Hi #{student.name}")
            expect(page).to have_content('You should also go through our coaching guide')
          end
        end

        context 'with no subscriptions' do
          before do
            no_subs = Fabricate(:member)
            login(no_subs)
            visit workshop_path(workshop)
          end

          it 'will be prompted to manage their subscriptions' do
            expect(page).to have_content('Please tell us whether you want to attend as a student or coach.')

            click_link 'Please tell us whether you want to attend as a student or coach.'
            expect(page).to have_current_path(subscriptions_path)
          end

          it 'cannot access RSVP as a student or coach' do
            expect(page).not_to have_content('Attend as a student')
            expect(page).not_to have_content('Attend as a coach')
          end
        end
      end

      context 'managing invitations' do
        before do
          login(coach)
          visit workshop_path(workshop)
        end

        context 'when auto RSVP open time is past, invitable turned off' do
          it 'can access RSVP as a coach' do
            visit workshop_path(workshop_auto_rsvp_in_past)

            click_on 'Attend as a coach'
            click_on 'Attend'

            expect(page).to have_content('See you at the workshop')
          end

          after do
            visit workshop_path(workshop_auto_rsvp_in_past)
            expect(page).to have_button('Manage your invitation')
          end
        end

        context 'when auto RSVP open time is future, invitable turned off' do
          it 'cannot access RSVP as a student or coach' do
            visit workshop_path(workshop_auto_rsvp_in_future)

            expect(page).to have_content('This workshop is not yet open for RSVP.')
          end
        end

        context 'when invitations have been sent out' do
          let(:member) { Fabricate(:member) }
          let!(:invitation) { Fabricate(:attending_workshop_invitation, member: member, workshop: workshop) }

          it 'can manage details if they are already attending' do
            login(member)
            visit workshop_path(workshop)

            expect(page).to have_button('Manage your invitation')
            expect(page).not_to have_link('Attend as a student')
            expect(page).not_to have_link('Attend as a coach')
          end
        end
      end
    end

    context '#past workshop' do
      let(:workshop) { Fabricate(:workshop, date_and_time: 2.weeks.ago) }

      scenario 'cannot interact with a past event' do
        visit workshop_path(workshop)
        expect(page).to have_content('has already taken place')
      end
    end
  end
end
