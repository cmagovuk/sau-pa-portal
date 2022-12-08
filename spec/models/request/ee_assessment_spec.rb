require "rails_helper"

RSpec.describe Request::EeAssessment, type: :model do
  describe "validations" do
    it { should allow_value("Hi " * 500).for(:assess_ee_pa) }
    it { should_not allow_value("Hi " * 501).for(:assess_ee_pa) }
    it { should allow_value("Hi " * 500).for(:assess_ee_pb) }
    it { should_not allow_value("Hi " * 501).for(:assess_ee_pb) }
    it { should allow_value("Hi " * 500).for(:assess_ee_pc) }
    it { should_not allow_value("Hi " * 501).for(:assess_ee_pc) }
    it { should allow_value("Hi " * 500).for(:assess_ee_pd) }
    it { should_not allow_value("Hi " * 501).for(:assess_ee_pd) }
    it { should allow_value("Hi " * 500).for(:assess_ee_pe) }
    it { should_not allow_value("Hi " * 501).for(:assess_ee_pe) }
    it { should allow_value("Hi " * 500).for(:assess_ee_pf) }
    it { should_not allow_value("Hi " * 501).for(:assess_ee_pf) }
    it { should allow_value("Hi " * 500).for(:assess_ee_pg) }
    it { should_not allow_value("Hi " * 501).for(:assess_ee_pg) }
    it { should allow_value("Hi " * 500).for(:assess_ee_ph) }
    it { should_not allow_value("Hi " * 501).for(:assess_ee_ph) }
    it { should allow_value("Hi " * 500).for(:assess_ee_pi) }
    it { should_not allow_value("Hi " * 501).for(:assess_ee_pi) }
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
