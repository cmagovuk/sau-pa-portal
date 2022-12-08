require "rails_helper"

RSpec.describe RequestsHelper, type: :helper do
  describe "#select_filter_options" do
    it { expect(helper.select_filter_options([])).to eq([["No filter", ""]]) }
    it { expect(helper.select_filter_options(%w[One])).to eq([["No filter", ""], %w[One One]]) }
    it { expect(helper.select_filter_options(%w[One Two])).to eq([["No filter", ""], %w[One One], %w[Two Two]]) }
  end
end
