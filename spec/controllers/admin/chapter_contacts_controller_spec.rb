require 'rails_helper'

RSpec.describe Admin::ChapterContactsController do
  let(:organiser) { Fabricate(:member) }
  let(:chapter) { Fabricate(:chapter) }
  let(:member) { Fabricate(:member) }
  let(:group) { Fabricate(:group, name: 'Students', chapter:) }

  before do
    organiser.add_role(:organiser, chapter)
    Fabricate(:subscription, member:, group:)
    login(organiser)
    ActionMailer::Base.deliveries.clear
  end

  describe 'POST #preview' do
    render_views

    it 'persists a short-lived, sender- and chapter-bound recipient snapshot' do
      post :preview, params: {
        chapter_id: chapter.id,
        chapter_contact: { subject: 'Update', message: 'Hello chapter' }
      }

      token = confirmation_token
      confirmation = ChapterContactConfirmation.last
      expect(response).to be_successful
      expect(confirmation.chapter).to eq(chapter)
      expect(confirmation.sender).to eq(organiser)
      expect(confirmation.subject).to eq('Update')
      expect(confirmation.message).to eq('Hello chapter')
      expect(confirmation.recipient_ids).to eq([member.id])
      expect(confirmation.expires_at).to be_within(1.second).of(30.minutes.from_now)
      expect(confirmation.token_digest).to eq(Digest::SHA256.hexdigest(token))
    end

    it 'restricts a custom list to current members of the chapter' do
      outsider = Fabricate(:member)

      post :preview, params: {
        chapter_id: chapter.id,
        chapter_contact: {
          audience: 'custom_list',
          member_ids: [member.id, outsider.id],
          subject: 'Update',
          message: 'Hello selected members'
        }
      }

      expect(ChapterContactConfirmation.last.recipient_ids).to eq([member.id])
    end

    it 'rejects RSVP audiences for events outside the chapter' do
      other_event = Fabricate(:event)
      Fabricate(:invitation, event: other_event, member:, attending: true)

      post :preview, params: {
        chapter_id: chapter.id,
        chapter_contact: {
          audience: 'event_rsvp',
          event_id: other_event.id,
          rsvp_status: 'attending',
          subject: 'Update',
          message: 'Hello event attendees'
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('No current chapter members match that event RSVP status.')
      expect(ChapterContactConfirmation.count).to eq(0)
    end
  end

  describe 'POST #create' do
    render_views

    it 'does not send when confirmation was skipped' do
      expect do
        post :create, params: {
          chapter_id: chapter.id,
          chapter_contact: { subject: 'Direct', message: 'Bypass preview' }
        }
      end.not_to change(ActionMailer::Base.deliveries, :count)

      expect(response).to redirect_to(new_admin_chapter_contact_path(chapter))
      expect(flash[:alert]).to include('preview')
    end

    it 'sends the stored snapshot once and rejects replay' do
      outsider = Fabricate(:member)
      post :preview, params: {
        chapter_id: chapter.id,
        chapter_contact: { subject: 'Previewed subject', message: 'Previewed message' }
      }
      token = confirmation_token

      expect { confirm(token, subject: 'Tampered subject', message: 'Tampered message') }
        .to change(ActionMailer::Base.deliveries, :count).by(1)

      email = ActionMailer::Base.deliveries.last
      expect(email.to).to eq([member.email])
      expect(email.subject).to eq('Previewed subject')
      expect(email.body.encoded).to include('Previewed message')

      expect { confirm(token) }.not_to change(ActionMailer::Base.deliveries, :count)
      expect(delivered_emails_to(outsider)).to be_empty
      expect(flash[:alert]).to include('expired or already used')
    end

    it 'rejects an expired confirmation' do
      post :preview, params: {
        chapter_id: chapter.id,
        chapter_contact: { subject: 'Update', message: 'Hello chapter' }
      }
      confirmation = ChapterContactConfirmation.last
      token = confirmation_token
      confirmation.update!(expires_at: 1.second.ago)

      expect do
        post :create, params: {
          chapter_id: chapter.id,
          chapter_contact: { confirmation_token: token }
        }
      end.not_to change(ActionMailer::Base.deliveries, :count)

      expect(response).to redirect_to(new_admin_chapter_contact_path(chapter))
      expect(flash[:alert]).to include('expired or already used')
    end

    it 'rejects a confirmation belonging to another sender' do
      post :preview, params: {
        chapter_id: chapter.id,
        chapter_contact: { subject: 'Update', message: 'Hello chapter' }
      }
      token = confirmation_token
      another_organiser = Fabricate(:member)
      another_organiser.add_role(:organiser, chapter)
      login(another_organiser)

      expect do
        post :create, params: {
          chapter_id: chapter.id,
          chapter_contact: { confirmation_token: token }
        }
      end.not_to change(ActionMailer::Base.deliveries, :count)
      expect(response).to redirect_to(new_admin_chapter_contact_path(chapter))
      expect(flash[:alert]).to include('expired or already used')
    end

    it 'rejects a confirmation for a different chapter' do
      post :preview, params: {
        chapter_id: chapter.id,
        chapter_contact: { subject: 'Update', message: 'Hello chapter' }
      }
      token = confirmation_token
      other_chapter = Fabricate(:chapter)
      login_as_admin(Fabricate(:member))

      expect do
        post :create, params: {
          chapter_id: other_chapter.id,
          chapter_contact: { confirmation_token: token }
        }
      end.not_to change(ActionMailer::Base.deliveries, :count)
      expect(response).to redirect_to(new_admin_chapter_contact_path(other_chapter))
    end
  end

  def confirmation_token
    Nokogiri::HTML(response.body).at_css('input[name="chapter_contact[confirmation_token]"]')['value']
  end

  def confirm(token, **attributes)
    post :create, params: {
      chapter_id: chapter.id,
      chapter_contact: { confirmation_token: token }.merge(attributes)
    }
  end
end
