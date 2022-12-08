require "rails_helper"

RSpec.describe Request::CharacterDesc, type: :model do
  describe "validations" do
    it { should allow_value("Hi " * 500).for(:character_desc) }
    it { should_not allow_value("Hi " * 501).for(:character_desc) }

    it { should have_one_attached(:call_in) }
  end

  describe "#info_only?" do
    it "must not be info only view" do
      expect(subject).to_not be_info_only
    end
  end

  describe "#upload_step?" do
    it "must be upload step" do
      expect(subject).to be_upload_step
    end
  end
end
