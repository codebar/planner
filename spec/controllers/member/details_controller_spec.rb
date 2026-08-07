RSpec.describe Member::DetailsController do
  render_views
  let(:member) { Fabricate(:member) }
  let(:mailing_list) { instance_double(Services::MailingList) }

  before do
    allow(controller).to receive(:current_user).and_return(member)
    allow(Services::MailingList).to receive(:new).and_return(mailing_list)
    allow(mailing_list).to receive_messages(subscribe: true, unsubscribe: true)
  end

  describe 'GET #edit' do
    context 'when a brand-new member' do
      it 'shows the signing up message' do
        session[:new_member] = true

        get :edit

        expect(response.body).to include(I18n.t('notifications.signing_up'))
      end
    end

    context 'when an existing member' do
      it 'does not show the signing up message' do
        session[:new_member] = false

        get :edit

        expect(response.body).not_to include(I18n.t('notifications.signing_up'))
      end
    end
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
        expect(member.how_you_found_us_other_reason).to be_nil
        expect(response).to redirect_to(step2_member_path)
      end

      it 'adds other_reason to how_you_found_us when provided' do
        patch :update, params: {
          id: member.id,
          member: {
            how_you_found_us: 'other',
            how_you_found_us_other_reason: 'Saw a pamphlet',
            newsletter: 'false'
          }
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
          }
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
          }
        }

        member.reload
        expect(member.how_you_found_us).to eq('other')
        expect(member.how_you_found_us_other_reason).to eq('From a colleague')
        expect(response).to redirect_to(step2_member_path)
      end

      it 'subscribes to the newsletter when checked' do
        patch :update, params: {
          id: member.id,
          member: {
            how_you_found_us: 'social_media',
            newsletter: 'true'
          }
        }

        expect(mailing_list).to have_received(:subscribe)
        expect(mailing_list).not_to have_received(:unsubscribe)
      end

      it 'unsubscribes from the newsletter when unchecked' do
        patch :update, params: {
          id: member.id,
          member: {
            how_you_found_us: 'social_media',
            newsletter: 'false'
          }
        }

        expect(mailing_list).to have_received(:unsubscribe)
        expect(mailing_list).not_to have_received(:subscribe)
      end
    end

    context 'with a validation failure' do
      it 'keeps the newsletter checkbox checked when it was checked' do
        patch :update, params: {
          id: member.id,
          member: { newsletter: 'true' }
        }

        expect(response.body).to include('You must select one option')
        expect(response.body).to have_css('input#member_newsletter[checked]')
      end

      it 'keeps the newsletter checkbox unchecked when it was unchecked' do
        patch :update, params: {
          id: member.id,
          member: { newsletter: 'false' }
        }

        expect(response.body).to include('You must select one option')
        expect(response.body).to have_no_css('input#member_newsletter[checked]')
      end
    end

    context 'when update fails (invalid data)' do
      it 'error raised when no how you found us selection given' do
        patch :update, params: {
          id: member.id,
          member: {
            how_you_found_us: 'other',
            how_you_found_us_other_reason: nil
          }
        }

        expect(response.body).to include('You must select one option')
      end

      it 'error raised when both how you found us fields popoulated' do
        patch :update, params: {
          id: member.id,
          member: {
            how_you_found_us: 'from_a_friend',
            how_you_found_us_other_reason: 'something else'
          }
        }

        expect(response.body).to include('You must select one option')
      end
    end
  end
end
