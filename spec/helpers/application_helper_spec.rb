require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#analytics_tracking_id" do
    it "retrieves the value from the application configuration" do
      expect(Rails.application.config.x).to receive(:analytics_tracking_id)
      helper.analytics_tracking_id
    end
  end

  describe "#transparency_link" do
    it "retrieves the value from the application configuration" do
      expect(Rails.application.config.x).to receive(:transparency_link)
      helper.transparency_link
    end
  end

  describe "#title" do
    let(:title) { helper.content_for(:page_title) }

    before do
      helper.title(value)
    end

    context "for a blank value" do
      let(:value) { "" }
      it { expect(title).to eq("Request a Report from the Subsidy Advice Unit - GOV.UK") }
    end

    context "for a given page" do
      let(:value) { "Test Page" }
      it { expect(title).to eq("Test Page - Request a Report from the Subsidy Advice Unit - GOV.UK") }
    end
  end

  describe "#path_only" do
    it { expect(helper.path_only("https://www.domain.com:213/homepage")).to eq("/homepage") }
    it { expect(helper.path_only("https://www.domain.com:213/homepage/subpage")).to eq("/homepage/subpage") }
    it { expect(helper.path_only(nil)).to eq(nil) }
  end
end
