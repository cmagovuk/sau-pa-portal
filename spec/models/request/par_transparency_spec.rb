require "rails_helper"

RSpec.describe Request::ParTransparency, type: :model do
  describe "validations" do
    it { should validate_presence_of(:par_on_td) }
    it { should validate_inclusion_of(:par_on_td).in_array(%w[y n]) }
    it { should validate_length_of(:par_td_ref_no).is_at_most(20) }
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
