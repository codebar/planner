RSpec.describe Member::DetailsController do
  render_views
  let(:member) { Fabricate(:member) }

  before do
    allow(controller).to receive(:current_user).and_return(member)
    allow_any_instance_of(Services::MailingList).to receive(:subscribe).and_return(true)
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      it 'updates how_you_found_us with checkbox options' do
        patch :update, params: {
          id: member.id,
          member: {
            how_you_found_us: ['Social Media', 'From a friend'],
            newsletter: 'true'
          }
        }

        member.reload
        expect(member.how_you_found_us).to contain_exactly('Social Media', 'From a friend')
        expect(response).to redirect_to(step2_member_path)
      end

      it 'adds other_reason to how_you_found_us when provided' do
        patch :update, params: {
          id: member.id,
          member: {
            how_you_found_us: ['Search engine (Google etc.)'],
            how_you_found_us_other_reason: 'Saw a pamphlet',
            newsletter: 'false'
          },
        }

        member.reload
        expect(member.how_you_found_us).to contain_exactly('Search engine (Google etc.)', 'Saw a pamphlet')
        expect(response).to redirect_to(step2_member_path)
      end

      it 'updates how_you_found_us with only other_reason' do
        patch :update, params: {
          id: member.id,
          member: {
            how_you_found_us: [],
            how_you_found_us_other_reason: 'At a meetup',
            newsletter: 'true'
          },
        }

        member.reload
        expect(member.how_you_found_us).to eq(['At a meetup'])
        expect(response).to redirect_to(step2_member_path)
      end

      it 'removes duplicates and blank entries' do
        patch :update, params: {
          id: member.id,
          member: {
            how_you_found_us: ['From a friend', '', 'From a friend'],
            how_you_found_us_other_reason: 'From a friend',
            newsletter: 'true'
          },
        }

        member.reload
        expect(member.how_you_found_us).to eq(['From a friend'])
        expect(response).to redirect_to(step2_member_path)
      end
    end

    context 'when update fails (invalid data)' do
      it 'renders the edit template' do
        patch :update, params: {
          id: member.id,
          member: {
            how_you_found_us: []
          }
        }

        expect(response.body).to include('You must select at least one option')
      end
    end
  end
end
