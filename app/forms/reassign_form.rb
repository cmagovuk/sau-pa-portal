class ReassignForm
  include ActiveModel::Model

  attr_accessor :reassign_to

  validates :reassign_to, presence: true
end
