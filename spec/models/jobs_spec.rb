require 'spec_helper'

describe Job do
  context '#fields' do
    subject(:job) { Fabricate.build(:job) }

    it { should respond_to(:title) }
    it { should respond_to(:description) }
    it { should respond_to(:location) }
    it { should respond_to(:expiry_date) }
    it { should respond_to(:email) }
    it { should respond_to(:link_to_job) }
    it { should respond_to(:expiry_date) }
    it { should respond_to(:created_by) }
    it { should respond_to(:approved) }
    it { should respond_to(:submitted) }
  end

  context 'scopes' do
    let!(:approved_jobs) { 2.times.map { Fabricate(:job) } }
    let!(:unsubmitted) { 1.times.map { Fabricate(:job, submitted: false, approved: false) } }
    let!(:pending_approval) { 4.times.map { Fabricate(:job, approved: false) } }
    let!(:expired) { 2.times.map { Fabricate(:job, expiry_date: 1.week.ago) } }

    it '#default_scope does not return expired jobs' do
      expect(Job.submitted.all).to eq(pending_approval)
    end

    it '#approved returns all approved jobs' do
      expect(Job.approved.all).to eq(approved_jobs + expired)
    end

    it '#not_submitted returns all jobs who have not yet been previed' do
      expect(Job.not_submitted.all).to eq(unsubmitted)
    end

    it '#submitted returns all submitted jobs' do
      expect(Job.submitted.all).to eq(pending_approval)
    end

    it '#active returns all active jobs' do
      expect(Job.active.all).to eq(approved_jobs + unsubmitted + pending_approval)
    end
  end

  context '#expired?' do
    it 'checks if the job post has past its expiry_date' do
      job = Job.new(expiry_date: 1.day.ago)

      expect(job.expired?).to eq(true)
    end
  end
end
