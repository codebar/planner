RSpec.describe Member::DetailsController do
  render_views
  let(:member) { Fabricate(:member) }

  before do
    allow(controller).to receive(:current_user).and_return(member)
    allow_any_instance_of(Services::MailingList).to receive(:subscribe).and_return(true)
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      it 'updates how_you_found_us with radio option' do
        patch :update, params: {
          id: member.id,
          member: {
            how_you_found_us: 'social_media',
            newsletter: 'true'
          }
        }

        member.reload
        expect(I18n.t("member.details.edit.how_you_found_us_options.#{member.how_you_found_us}")).to eq('Social media')
        expect(member.how_you_found_us_other_reason).to eq(nil)
        expect(response).to redirect_to(step2_member_path)
      end

      it 'adds other_reason to how_you_found_us when provided' do
        patch :update, params: {
          id: member.id,
          member: {
            how_you_found_us: 'other',
            how_you_found_us_other_reason: 'Saw a pamphlet',
            newsletter: 'false'
          },
        }

        member.reload
        expect(member.how_you_found_us).to eq('other')
        expect(member.how_you_found_us_other_reason).to eq('Saw a pamphlet')
        expect(response).to redirect_to(step2_member_path)
      end

      it 'updates how_you_found_us with only other_reason' do
        patch :update, params: {
          id: member.id,
          member: {
            how_you_found_us: 'other',
            how_you_found_us_other_reason: 'At a meetup',
            newsletter: 'true'
          },
        }

        member.reload
        expect(member.how_you_found_us).to eq('other')
        expect(member.how_you_found_us_other_reason).to eq('At a meetup')
        expect(response).to redirect_to(step2_member_path)
      end

      it 'removes duplicates and blank entries' do
        patch :update, params: {
          id: member.id,
          member: {
            how_you_found_us: 'other',
            how_you_found_us_other_reason: 'From a colleague',
            newsletter: 'true'
          },
        }

        member.reload
        expect(member.how_you_found_us).to eq('other')
        expect(member.how_you_found_us_other_reason).to eq('From a colleague')
        expect(response).to redirect_to(step2_member_path)
      end
    end

    context 'when update fails (invalid data)' do
      it 'error raised when no how you found us selection given' do
        patch :update, params: {
          id: member.id,
          member: {
            how_you_found_us: 'other',
            how_you_found_us_other_reason: nil,
          }
        }

        expect(response.body).to include('You must select one option')
      end

      it 'error raised when both how you found us fields popoulated' do
        patch :update, params: {
          id: member.id,
          member: {
            how_you_found_us: 'from_a_friend',
            how_you_found_us_other_reason: 'something else',
          }
        }

        expect(response.body).to include('You must select one option')
      end

    end
  end
end
