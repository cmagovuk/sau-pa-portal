class AssignSubForm
  include ActiveModel::Model

  attr_accessor :sub_authority

  validates :sub_authority, presence: true
  validate :valid_sub_authority

  def valid_sub_authority
    # Check authority doesn't have sub authorities of it's own
    sub_auth = PublicAuthority.find(sub_authority)
    errors.add(:sub_authority, :has_sub_authorities) if sub_auth.sub_authorities.count.positive?
  end
end
