# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Chapter contact access' do
  let(:chapter) { Fabricate(:chapter) }

  let(:contact_routes) do
    Rails.application.routes.routes.select { |route| route.defaults[:controller] == 'admin/chapter_contacts' }
  end

  def sign_in(member)
    Fabricate(:auth_service, member:, provider: 'github', uid: "uid-#{member.id}")
    mock_auth_hash(provider: 'github', uid: "uid-#{member.id}", email: member.email)
    post '/auth/github/callback'
  end

  def request_route(route)
    path = route.path.spec.to_s.sub('(.:format)', '').sub(':chapter_id', chapter.id.to_s)
    verb = route.verb.downcase
    public_send(verb, path, params: { chapter_contact: { subject: 's', message: 'm', audience: 'all_members' } })
  end

  def expect_blocked(routes, redirect)
    ActionMailer::Base.deliveries.clear

    routes.each do |route|
      request_route(route)

      expect(response).to redirect_to(redirect), "#{route.verb} #{route.path.spec} was reachable"
    end
    expect_nothing_sent
  end

  def expect_nothing_sent
    expect(ActionMailer::Base.deliveries).to be_empty
    expect(ChapterContactConfirmation.count).to eq(0)
    expect(enqueued_jobs_count).to eq(0)
  end

  def self.blocked_for(description, redirect: -> { root_path }, except: [], &setup)
    context "when #{description}" do
      before { instance_exec(&setup) }

      it 'is redirected away from every chapter contact route and nothing is sent' do
        routes = contact_routes.reject { |route| except.include?(route.defaults[:action]) }
        expect(routes).not_to be_empty

        expect_blocked(routes, instance_exec(&redirect))
      end
    end
  end

  def enqueued_jobs_count = ActiveJob::Base.queue_adapter.try(:enqueued_jobs)&.size.to_i

  blocked_for('logged out') { nil }

  blocked_for('a member with no role') { sign_in(Fabricate(:member)) }

  blocked_for('a student') do
    sign_in(Fabricate(:member).tap { |m| Fabricate(:subscription, member: m, group: Fabricate(:students, chapter:)) })
  end

  blocked_for('a coach') do
    sign_in(Fabricate(:member).tap { |m| Fabricate(:subscription, member: m, group: Fabricate(:coaches, chapter:)) })
  end

  # The index only lists the chapters the organiser manages, so it is reachable.
  blocked_for('an organiser of another chapter', except: %w[index]) do
    sign_in(Fabricate(:member).tap { |m| m.add_role(:organiser, Fabricate(:chapter)) })
  end

  blocked_for('a banned chapter organiser') do
    sign_in(Fabricate(:member).tap do |m|
      m.add_role(:organiser, chapter)
      Fabricate(:ban, member: m)
    end)
  end

  blocked_for('a banned admin') do
    sign_in(Fabricate(:member).tap do |m|
      m.add_role(:admin)
      Fabricate(:ban, member: m)
    end)
  end

  blocked_for('an organiser who has not accepted the terms', redirect: -> { terms_and_conditions_path }) do
    sign_in(Fabricate(:member_without_toc).tap { |m| m.add_role(:organiser, chapter) })
  end

  context 'when an admin' do
    it 'can reach the contact form' do
      sign_in(Fabricate(:member).tap { |m| m.add_role(:admin) })

      get new_admin_chapter_contact_path(chapter)

      expect(response).to have_http_status(:ok)
    end
  end
end
