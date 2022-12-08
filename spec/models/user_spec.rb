require "rails_helper"

RSpec.describe User, type: :model do
  user_role_options = %w[su].freeze

  describe "validations" do
    it { should validate_presence_of(:user_name) }
    it { should validate_presence_of(:email) }
    it { should validate_length_of(:user_name).is_at_most(255) }
    it { should validate_length_of(:email).is_at_most(255) }
    it { should validate_length_of(:phone).is_at_most(30) }
    it { should validate_inclusion_of(:role).in_array(user_role_options) }

    it { should allow_value("name@company.com").for(:email) }
    it { should allow_value("nAmE@comPany.COM").for(:email) }
    it { should_not allow_value("name@company@company.com").for(:email) }

    it { should_not allow_value("abc.def@mail").for(:email) }
    it { should_not allow_value("abc.def@mail.c").for(:email) }
  end

  describe "valid email uniqueness" do
    before(:example) do
      @pa = PublicAuthority.create!(pa_name: "Test PA")
    end

    subject { User.new(email: "text@example.com", public_authority_id: @pa.id, user_name: "Test", role: "su") }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end
end
