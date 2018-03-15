# frozen_string_literal: true

RSpec.describe PKZ::Payment::Start do
  describe "SCHEMA" do
    # let!(schema) { PKZ::Payment::Start::SCHEMA }

    describe "merchant_id" do
      it "validates presense" do
        errors = PKZ::Payment::Start::SCHEMA.call({}).messages
        expect(errors[:merchant_id]).to include("is missing")
      end
    end
  end
end
