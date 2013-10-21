require 'spec_helper'

describe Member do
  context "mandatory attributes" do
    context "validations" do
      context "presence" do
        it "#name" do
          member = Fabricate.build(:member, name: nil)

          member.should_not be_valid
          member.should have(1).error_on(:name)
        end

        it "#surname" do
          member = Fabricate.build(:member, surname: nil)

          member.should_not be_valid
          member.should have(1).error_on(:surname)
        end

        it "#email" do
          member = Fabricate.build(:member, email: nil)

          member.should_not be_valid
          member.should have(1).error_on(:email)
        end

        it "#about_you" do
          member = Fabricate.build(:member, about_you: nil)

          member.should_not be_valid
          member.should have(1).error_on(:about_you)
        end

      end
    end

    context "uniqueness" do
      it "#email" do
        Fabricate(:member, email: "sample@email.com")

        expect { Fabricate(:member, email: "sample@email.com") }.to raise_error
      end
    end
  end
end
