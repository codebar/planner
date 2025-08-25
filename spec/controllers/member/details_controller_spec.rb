RSpec.describe Member::DetailsController, type: :controller do
  render_views
  let(:member) { Fabricate(:member) }

  before do
    allow(controller).to receive(:current_user).and_return(member)
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
            newsletter: 'false'
          },
          other_reason: 'Saw a flyer'
        }

        member.reload
        expect(member.how_you_found_us).to contain_exactly('Search engine (Google etc.)', 'Saw a flyer')
        expect(response).to redirect_to(step2_member_path)
      end

      it 'updates how_you_found_us with only other_reason' do
        patch :update, params: {
          id: member.id,
          member: {
            how_you_found_us: [],
            newsletter: 'true'
          },
          other_reason: 'At a meetup'
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
            newsletter: 'true'
          },
          other_reason: 'From a friend'
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
