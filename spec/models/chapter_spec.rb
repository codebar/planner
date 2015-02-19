require 'spec_helper'

describe Chapter do

  context "validations" do
    context "#slug" do
      it "a chapter must have a slug set" do
        chapter = Chapter.new(name: "London", city: "London", email: "london@codebar.io")
        chapter.save

        expect(chapter.slug).to eq("london")
      end

      it "the slug is parameterized" do
        chapter = Chapter.new(name: "New York", city: "New York", email: "newyork@codebar.io")
        chapter.save

        expect(chapter.slug).to eq("new-york")
      end
    end
  end
end
