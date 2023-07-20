require "rails_helper"

RSpec.describe InformationRequest, type: :model do
  describe "validations" do
    it { should have_many_attached(:request_doc) }
    it { should have_many_attached(:response_doc) }
  end
end
