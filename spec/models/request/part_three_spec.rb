require "rails_helper"

RSpec.describe Request::PartThree, type: :model do
  describe "validations" do
    it { should allow_value("Hi " * 500).for(:p3_description) }
    it { should_not allow_value("Hi " * 501).for(:p3_description) }
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
