require "rails_helper"

RSpec.describe Request::Assessment, type: :model do
  describe "validations" do
    it { should allow_value("Hi " * 500).for(:assess_pa) }
    it { should_not allow_value("Hi " * 501).for(:assess_pa) }
    it { should allow_value("Hi " * 500).for(:assess_pb) }
    it { should_not allow_value("Hi " * 501).for(:assess_pb) }
    it { should allow_value("Hi " * 500).for(:assess_pc) }
    it { should_not allow_value("Hi " * 501).for(:assess_pc) }
    it { should allow_value("Hi " * 500).for(:assess_pd) }
    it { should_not allow_value("Hi " * 501).for(:assess_pd) }
    it { should allow_value("Hi " * 500).for(:assess_pe) }
    it { should_not allow_value("Hi " * 501).for(:assess_pe) }
    it { should allow_value("Hi " * 500).for(:assess_pf) }
    it { should_not allow_value("Hi " * 501).for(:assess_pf) }
    it { should allow_value("Hi " * 500).for(:assess_pg) }
    it { should_not allow_value("Hi " * 501).for(:assess_pg) }

    it { should have_many_attached(:assessment_docs) }
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
