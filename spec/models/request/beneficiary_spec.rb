require "rails_helper"

RSpec.describe Request::Beneficiary, type: :model do
  describe "validations" do
    it { should validate_length_of(:beneficiary).is_at_most(255) }
    it { should validate_length_of(:ben_id).is_at_most(50) }
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
