require "rails_helper"

RSpec.describe PublicAuthority, type: :model do
  describe "validations" do
    it { should validate_presence_of(:pa_name) }
    it { should validate_length_of(:pa_name).is_at_most(255) }
  end

  describe "valid name uniqueness" do
    it { should validate_uniqueness_of(:pa_name).case_insensitive }
  end
end
