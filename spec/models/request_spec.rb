require "rails_helper"

RSpec.describe Request, type: :model do
  describe "#info_only?" do
    it "must be info only view" do
      expect(subject).to be_info_only
    end
  end

  describe "#field_too_long" do
    it "default to 500 words" do
      expect(subject.field_too_long("Ho ")).to eq(false)
      expect(subject.field_too_long("Ho " * 50)).to eq(false)
      expect(subject.field_too_long("Ho " * 51)).to eq(false)
      expect(subject.field_too_long("Ho " * 500)).to eq(false)
      expect(subject.field_too_long("Ho " * 501)).to eq(true)
    end

    it "default can be changed" do
      expect(subject.field_too_long("Ho ", 50)).to eq(false)
      expect(subject.field_too_long("Ho " * 50, 50)).to eq(false)
      expect(subject.field_too_long("Ho " * 51, 50)).to eq(true)
      expect(subject.field_too_long("Ho " * 500, 50)).to eq(true)
      expect(subject.field_too_long("Ho " * 501, 50)).to eq(true)
    end
  end

  describe "#determine_required_fields?" do
    it "default list" do
      expect(subject.determine_required_fields).to match_array(%w[referral_type description is_nc ee_assess_required is_c2_relevant character_desc])
    end
    it "when tax subsidy" do
      subject = described_class.new(scheme_subsidy: "subsidy", subsidy_form: "tax")
      expect(subject.determine_required_fields).to match_array(%w[referral_type description is_nc ee_assess_required is_c2_relevant subsidy_form ben_id_type ben_id beneficiary ben_size legal policy confirm_date character_desc tax_amt])
    end
    it "when loan subsidy" do
      subject = described_class.new(scheme_subsidy: "subsidy", subsidy_form: "loan", ee_assess_required: "n")
      expect(subject.determine_required_fields).to match_array(%w[referral_type description is_nc ee_assess_required is_c2_relevant subsidy_form ben_id_type ben_id beneficiary ben_size legal policy confirm_date character_desc budget])
    end
    it "when loan subsidy with e&e assessment" do
      subject = described_class.new(scheme_subsidy: "subsidy", subsidy_form: "loan", ee_assess_required: "y")
      expect(subject.determine_required_fields).to match_array(%w[referral_type description is_nc ee_assess_required is_c2_relevant subsidy_form ben_id_type ben_id beneficiary ben_size legal policy confirm_date character_desc budget])
    end
    it "when scheme" do
      subject = described_class.new(scheme_subsidy: "scheme", ee_assess_required: "n")
      expect(subject.determine_required_fields).to match_array(%w[scheme_name budget legal policy confirm_date start_date referral_type description is_nc ee_assess_required is_c2_relevant character_desc])
    end
    it "when scheme with other form" do
      subject = described_class.new(scheme_subsidy: "scheme", ee_assess_required: "n", subsidy_forms: %w[loan tax other])
      expect(subject.determine_required_fields).to match_array(%w[scheme_name budget legal policy confirm_date start_date referral_type description is_nc ee_assess_required is_c2_relevant character_desc other_form])
    end
    it "when scheme with chapter 2" do
      subject = described_class.new(scheme_subsidy: "scheme", is_c2_relevant: "y")
      expect(subject.determine_required_fields).to match_array(%w[scheme_name budget legal policy confirm_date start_date referral_type description is_nc ee_assess_required is_c2_relevant c2_description character_desc])
    end
    it "when scheme with e&e assessment" do
      subject = described_class.new(scheme_subsidy: "scheme", ee_assess_required: "y")
      expect(subject.determine_required_fields).to match_array(%w[scheme_name budget legal policy confirm_date start_date referral_type description is_nc ee_assess_required is_c2_relevant character_desc])
    end
    it "when scheme call in" do
      subject = described_class.new(referral_type: "call", scheme_subsidy: "scheme")
      expect(subject.determine_required_fields).to match_array(%w[scheme_name budget legal policy confirm_date start_date referral_type direction_date call_in_type description is_nc ee_assess_required is_c2_relevant character_desc])
    end
    it "when scheme PAR not on TD" do
      subject = described_class.new(referral_type: "par", scheme_subsidy: "scheme", par_on_td: "n")
      expect(subject.determine_required_fields).to match_array(%w[referral_type description is_nc direction_date par_on_td par_assessed scheme_name budget legal policy confirm_date start_date ee_assess_required is_c2_relevant])
    end
    it "when scheme PAR on TD accessed" do
      subject = described_class.new(referral_type: "par", scheme_subsidy: "scheme", par_on_td: "y", par_assessed: "y")
      expect(subject.determine_required_fields).to match_array(%w[referral_type description is_nc direction_date par_on_td par_td_ref_no par_assessed ee_assess_required is_c2_relevant])
    end
    it "when scheme PAR on TD not accessed" do
      subject = described_class.new(referral_type: "par", scheme_subsidy: "scheme", par_on_td: "y", par_assessed: "n")
      expect(subject.determine_required_fields).to match_array(%w[referral_type description is_nc direction_date par_on_td par_td_ref_no par_assessed par_reason])
    end
  end
end
