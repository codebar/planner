# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'rake member:subkeyed', type: :task do
  let(:subkeyed_key) { 'aB3xK9mQ7vN2pR5sT8uW1yZ4cD6fG0hJ' }

  def create_subkeyed_member(key: subkeyed_key, name_value: 'Viktoriya Kravchenko')
    member = Member.new(email: key, name: name_value, surname: 'Kravchenko',
                        about_you: 'Created by the sub fallback', accepted_toc_at: Time.zone.now)
    member.save(validate: false)
    member.auth_services.create!(provider: 'codebar', uid: key)
    member
  end

  describe 'member:subkeyed:detect' do
    let(:task) { Rake::Task['member:subkeyed:detect'] }

    after { task.reenable }

    it 'preloads the Rails environment' do
      expect(task.prerequisites).to include 'environment'
    end

    it 'reports a match without changing anything' do
      member = create_subkeyed_member

      expect { task.execute }
        .to output(/detected=1/).to_stdout

      expect { member.reload }.not_to change(member, :email)
    end

    it 'reports zero when nothing matches' do
      Fabricate(:member)

      expect { task.execute }
        .to output(/detected=0/).to_stdout
    end
  end

  describe 'member:subkeyed:deactivate' do
    let(:task) { Rake::Task['member:subkeyed:deactivate'] }

    after { task.reenable }

    it 'preloads the Rails environment' do
      expect(task.prerequisites).to include 'environment'
    end

    it 'is a dry run by default: reports the action and writes nothing' do
      member = create_subkeyed_member

      expect { task.execute }
        .to output(/detected=1 deactivated=1 skipped=0/).to_stdout

      expect { member.reload }.not_to change(member, :email)
      expect(member.auth_services.where(provider: 'codebar')).to exist
      expect(MemberNote.where(member_id: member.id)).not_to exist
    end

    describe 'with EXECUTE=1' do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('EXECUTE').and_return('1')
      end

      it 'deactivates: renames email, removes auth services, adds a note' do
        member = create_subkeyed_member

        expect { task.execute }
          .to output(/detected=1 deactivated=1 skipped=0/).to_stdout

        member.reload
        expect(member.email).to eq("subkeyed.#{member.id}.deactivated@codebar.io")
        expect(member.auth_services).to be_empty
        expect(MemberNote.find_by(member_id: member.id).note).to include('better-auth user id')
      end

      it 'skips and reports a data-owning member' do
        member = create_subkeyed_member
        Fabricate(:subscription, member:)

        expect { task.execute }
          .to output(/detected=1 deactivated=0 skipped=1/).to_stdout

        member.reload
        expect(member.email).to eq(subkeyed_key)
        expect(member.subscriptions).to be_present
      end

      it 'is idempotent: a second run writes nothing new' do
        create_subkeyed_member
        task.execute

        expect { task.execute }.not_to change(MemberNote, :count)
      end

      it 'drops deactivated members out of detection' do
        create_subkeyed_member
        task.execute

        detect = Rake::Task['member:subkeyed:detect']
        expect { detect.execute }.to output(/detected=0/).to_stdout
      end
    end
  end

  describe 'member:subkeyed:verify' do
    let(:task) { Rake::Task['member:subkeyed:verify'] }

    after { task.reenable }

    # One execute, stdout captured, SystemExit contained. rspec-core re-raises
    # SystemExit without recording a failure, and an escaped exit poisons the
    # parallel-test child's exit code even when every example is green.
    def run_verify
      captured = StringIO.new
      original_stdout = $stdout
      $stdout = captured
      status = begin
        task.execute
        nil
      rescue SystemExit => e
        e.status
      ensure
        $stdout = original_stdout
      end
      [captured.string, status]
    end

    it 'preloads the Rails environment' do
      expect(task.prerequisites).to include 'environment'
    end

    it 'fails with exit status 1, a FAIL line, and the unhandled member id' do
      member = create_subkeyed_member

      output, status = run_verify

      expect(status).to eq(1)
      expect(output).to include('FAIL: 1 deactivatable sub-keyed member(s) still active:')
      expect(output).to include("member #{member.id}")
    end

    it 'passes when a sub-keyed member is skipped (handled by report)' do
      member = create_subkeyed_member
      Fabricate(:subscription, member:)

      output, status = run_verify

      expect(status).to be_nil
      expect(output).to include('skipped member')
    end

    it 'passes after deactivation' do
      create_subkeyed_member
      Rake::Task['member:subkeyed:deactivate'].execute # dry run does not write

      # Execute for real:
      deactivate = Rake::Task['member:subkeyed:deactivate']
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('EXECUTE').and_return('1')
      deactivate.execute
      deactivate.reenable

      _output, status = run_verify

      expect(status).to be_nil
    end

    it 'passes when no sub-keyed members exist' do
      Fabricate(:member)

      _output, status = run_verify

      expect(status).to be_nil
    end
  end
end
