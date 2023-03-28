require "rails_helper"

RSpec.describe Request::Purpose, type: :model do
  describe "validations" do
    it { should validate_length_of(:other_purpose).is_at_most(255) }
  end

  describe "#info_only?" do
    it "must not be info only view" do
      expect(subject).to_not be_info_only
    end
  end

  describe "#upload_step?" do
    it "must not be upload step" do
      expect(subject).to_not be_upload_step
    end
  end
end
