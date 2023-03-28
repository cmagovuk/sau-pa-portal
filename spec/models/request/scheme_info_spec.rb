require "rails_helper"

RSpec.describe Request::SchemeInfo, type: :model do
  describe "validations" do
    it { should validate_presence_of(:scheme_name) }
    it { should validate_length_of(:max_amt_s).is_at_most(255) }
    it { should validate_numericality_of(:budget).is_less_than(10_000_000_000_000) }
    it { should validate_numericality_of(:budget).is_greater_than(0) }
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
