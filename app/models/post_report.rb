class PostReport < ApplicationRecord
  belongs_to :request

  serialize :completed_steps, Array

  REL_OPTIONS = %w[rel not_rel].freeze

  def permitted
    %w[].freeze
  end

  # allow pages that don't update object, such as information and confirmation pages
  def info_only?
    permitted.empty?
  end
end
