class ReassignForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::AttributeAssignment

  attr_accessor :reassign_to

  attribute :param

  OPTIONS = %w[reassign_to].freeze

  validates :reassign_to, presence: true

end
