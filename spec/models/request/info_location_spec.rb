require "rails_helper"

RSpec.describe Request::InfoLocation, type: :model do
  describe "validations" do
    it { should allow_value("Hi " * 500).for(:info_location) }
    it { should_not allow_value("Hi " * 501).for(:info_location) }
  end

  describe "#info_only?" do
    it "must not be info only view" do
      expect(subject).to_not be_info_only
    end
  end

  describe "#upload_step?" do
    it "must be upload step" do
      expect(subject).to_not be_upload_step
    end
  end
end
