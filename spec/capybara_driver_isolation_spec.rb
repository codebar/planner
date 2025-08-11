require 'spec_helper'

RSpec.describe "Capybara driver isolation in spec types feature, system and neither", order: :defined do
  context "feature spec", type: :feature do
    it "uses default driver (rack_test) for non JavaScript test" do
      expect(Capybara.current_driver).to eq(Capybara.default_driver)
    end

    it "uses JavaScript driver (chrome) when test is js: true", js: true do
      expect(Capybara.current_driver).to eq(Capybara.javascript_driver)
    end

    it "reverts to default driver (rack_test) after JavaScript test" do
      expect(Capybara.current_driver).to eq(Capybara.default_driver)
    end
  end

  context "system spec", type: :system do
    it "uses default driver (rack_test) for non JavaScript test" do
      expect(Capybara.current_driver).to eq(Capybara.default_driver)
    end

    it "uses JavaScript driver (chrome) for js: true test", js: true do
      expect(Capybara.current_driver).to eq(Capybara.javascript_driver)
    end

    it "reverts to default driver (rack_test) after JavaScript test" do
      expect(Capybara.current_driver).to eq(Capybara.default_driver)
    end
  end

  context "plain RSpec spec (no type)" do
    it "does not change Capybara driver (rack_test) unless manually set" do
      expect(Capybara.current_driver).to eq(Capybara.default_driver)
    end

    it "allows js: true metadata but does not use JavaScript driver", js: true do
      # In specs with no type, Capybara doesn't change driver unless configured manually
      expect(Capybara.current_driver).to eq(Capybara.default_driver)
    end

    it "the driver is default driver (rack_test) after JavaScript test" do
      expect(Capybara.current_driver).to eq(Capybara.default_driver)
    end
  end
end