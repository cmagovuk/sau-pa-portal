require "rails_helper"

RSpec.describe Request::ReferralType, type: :model do
  scheme_options = %w[sspi ssi call par].freeze
  subsidy_options = %w[spi soi call par].freeze

  describe "scheme validations" do
    subject { described_class.new(scheme_subsidy: "scheme") }

    it { should validate_presence_of(:referral_type) }

    it "validate include in scheme types" do
      should validate_inclusion_of(:referral_type).in_array(scheme_options)
    end
  end

  describe "subsidy validations" do
    subject { described_class.new(scheme_subsidy: "subsidy") }

    it { should validate_presence_of(:referral_type) }

    it "validate include in subsidy types" do
      should validate_inclusion_of(:referral_type).in_array(subsidy_options)
    end
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
