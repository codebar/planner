require "spec_helper"

RSpec.describe ApplicationHelper, :type => :helper do

  describe "#contact_email" do
    it "returns the workshop chapter's email" do
      @session = Fabricate(:sessions)
      expect(helper.contact_email).to eq(@session.chapter.email)
    end

    it "returns hello@codebar.io when no session is set" do
      expect(helper.contact_email).to eq("hello@codebar.io")
    end
  end
end
