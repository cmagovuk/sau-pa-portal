class Request::Purposes < Request
  PURPOSE_OPTIONS = %w[cultu emply energ envir infra regio rescu resea servi smesm train other].freeze

  # validate :atleast_one_selected
  validates :other_purpose, presence: { if: ->(o) { o.purposes.include?("other") } }, length: { maximum: 255 }

  def atleast_one_selected
    errors.add(:purposes, "Select at least one purpose") unless PURPOSE_OPTIONS.any? { |a| purposes.include?(a.to_s) }
  end

  def permitted
    [:other_purpose, { purposes: [] }].freeze
  end
end
