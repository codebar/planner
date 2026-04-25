RSpec.describe AsyncEmailConcern do
  let(:concern_class) do
    Class.new { include AsyncEmailConcern }
  end
  let(:instance) { concern_class.new }

  describe "#async_email_enabled?" do
    context "when ASYNC_EMAIL_CHAPTER_IDS is empty" do
      before { Rails.application.config.async_email_chapter_ids = [] }

      it "returns false" do
        expect(instance.send(:async_email_enabled?, OpenStruct.new(id: 1))).to be false
      end
    end

    context "when chapter is in async list" do
      before { Rails.application.config.async_email_chapter_ids = [1, 7] }

      it "returns true for matching chapter" do
        expect(instance.send(:async_email_enabled?, OpenStruct.new(id: 1))).to be true
      end

      it "returns false for non-matching chapter" do
        expect(instance.send(:async_email_enabled?, OpenStruct.new(id: 2))).to be false
      end
    end

    context "when chapter is nil" do
      it "returns false" do
        expect(instance.send(:async_email_enabled?, nil)).to be false
      end
    end
  end
end