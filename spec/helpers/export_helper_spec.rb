require "rails_helper"

RSpec.describe ExportHelper, type: :helper do
  describe "#map_free_text" do
    context "return bank" do
      it { expect(helper.map_free_text(nil, 5)).to be_blank }
      it { expect(helper.map_free_text("", 5)).to be_blank }
    end

    context "append ' ' if value starts with '='" do
      it { expect(helper.map_free_text("=1+3", 5)).to eq " =1+3" }
      it { expect(helper.map_free_text("==12", 5)).to eq " ==12" }
      it { expect(helper.map_free_text("=", 1)).to eq " " }
    end

    context "truncate string to max size" do
      it { expect(helper.map_free_text("=1+3", 4)).to eq " =1+" }
      it { expect(helper.map_free_text("1234567890", 5)).to eq "12345" }
      it { expect(helper.map_free_text("1234567890", 255)).to eq "1234567890" }
      it { expect(helper.map_free_text("1234567890", 0)).to eq "" }
      it { expect(helper.map_free_text("1234567890", -1)).to be_nil }
      it { expect(helper.map_free_text("1234567890", -10)).to be_nil }
    end
  end

  describe "#map_purpose" do
    context "return blank" do
      it { expect(helper.map_purpose(nil)).to be_blank }
      it { expect(helper.map_purpose([])).to be_blank }
      it { expect(helper.map_purpose([""])).to be_blank }
    end

    context "it outputs a text value for each possible purpose value" do
      Request::Purposes::PURPOSE_OPTIONS.each do |opt|
        it "for purpose '#{opt}'" do
          expect(helper.map_purpose([opt])).to_not be_blank
        end
      end
    end

    context "it outputs first not blank value" do
      it { expect(helper.map_purpose([""] + Request::Purposes::PURPOSE_OPTIONS[2..4])).to eq(helper.map_purpose([Request::Purposes::PURPOSE_OPTIONS[2]])) }
    end
  end

  describe "#map_subsidy_form" do
    context "return blank" do
      it { expect(helper.map_subsidy_form(nil)).to be_blank }
      it { expect(helper.map_subsidy_form("")).to be_blank }
      it { expect(helper.map_subsidy_form("incorrect value")).to be_blank }
    end

    context "it outputs a text value for each possible subsidy form value" do
      Request::SubsidyInfo::SUBSIDY_FORM_OPTIONS.each do |opt|
        it "for subsidy form '#{opt}'" do
          expect(helper.map_subsidy_form(opt)).to_not be_blank
        end
      end
    end
  end

  describe "#map_tax_amount" do
    context "return blank" do
      it { expect(helper.map_tax_amount(nil)).to be_blank }
      it { expect(helper.map_tax_amount("")).to be_blank }
      it { expect(helper.map_tax_amount("incorrect value")).to be_blank }
    end

    context "it outputs a text value for each possible tax amount value" do
      Request::TAX_OPTIONS.each do |opt|
        it "for tax amount '#{opt}'" do
          expect(helper.map_tax_amount(opt)).to_not be_blank
        end
      end
    end
  end

  describe "#map_ben_id_type" do
    context "return blank" do
      it { expect(helper.map_ben_id_type(nil)).to be_blank }
      it { expect(helper.map_ben_id_type("")).to be_blank }
      it { expect(helper.map_ben_id_type("incorrect value")).to be_blank }
    end

    context "it outputs a text value for each possible beneficiary id type value" do
      Request::Beneficiary::BEN_ID_TYPE_OPTIONS.each do |opt|
        it "for beneficiary id type '#{opt}'" do
          expect(helper.map_ben_id_type(opt)).to_not be_blank
        end
      end
    end
  end

  describe "#map_ben_size" do
    context "return blank" do
      it { expect(helper.map_ben_size(nil)).to be_blank }
      it { expect(helper.map_ben_size("")).to be_blank }
      it { expect(helper.map_ben_size("incorrect value")).to be_blank }
    end

    context "it outputs a text value for each possible beneficiary size value" do
      Request::Beneficiary::BEN_SIZE_OPTIONS.each do |opt|
        it "for beneficiary size '#{opt}'" do
          expect(helper.map_ben_size(opt)).to_not be_blank
        end
      end
    end
  end

  describe "#map_goods_services" do
    context "return blank" do
      it { expect(helper.map_goods_services(nil)).to be_blank }
      it { expect(helper.map_goods_services([])).to be_blank }
      it { expect(helper.map_goods_services([""])).to be_blank }
    end

    context "it outputs a text value for each possible value" do
      Request::GoodsServices::OPTIONS.each do |opt|
        it "for '#{opt}'" do
          expect(helper.map_goods_services([opt])).to_not be_blank
        end
      end
    end

    context "it outputs specific string 'Goods and Services' if both options in array" do
      it { expect(helper.map_goods_services([""] + Request::GoodsServices::OPTIONS)).to eq("Goods and Services") }
      it { expect(helper.map_goods_services(Request::GoodsServices::OPTIONS)).to eq("Goods and Services") }
    end
  end

  describe "#map_locations" do
    context "return blank" do
      it { expect(helper.map_locations(nil)).to be_blank }
      it { expect(helper.map_locations([])).to be_blank }
      it { expect(helper.map_locations([""])).to be_blank }
    end

    context "it outputs a text value for each possible location value" do
      Request::Locations::OPTIONS.each do |opt|
        it "for location '#{opt}'" do
          expect(helper.map_locations([opt])).to_not be_blank
        end
      end
    end

    context "it outputs first not blank value" do
      it { expect(helper.map_locations([""] + Request::Locations::OPTIONS[1..4])).to eq(helper.map_locations([Request::Locations::OPTIONS[1]])) }
    end
  end

  describe "#map_sectors" do
    context "return blank" do
      it { expect(helper.map_sectors(nil)).to be_blank }
      it { expect(helper.map_sectors([])).to be_blank }
      it { expect(helper.map_sectors([""])).to be_blank }
    end

    context "it outputs a text value for each possible location value" do
      Request::Sectors::SECTOR_OPTIONS.each do |opt|
        it "for location '#{opt}'" do
          expect(helper.map_sectors([opt])).to_not be_blank
        end
      end
    end

    context "it outputs first not blank value" do
      it { expect(helper.map_sectors([""] + Request::Sectors::SECTOR_OPTIONS[1..4])).to eq(helper.map_sectors([Request::Sectors::SECTOR_OPTIONS[1]])) }
    end
  end
end
