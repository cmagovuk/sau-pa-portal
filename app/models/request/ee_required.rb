class Request::EeRequired < Request
  OPTIONS = %w[y n].freeze

  # validates :ee_assess_required, presence: true
  # validates :ee_assess_required, inclusion: { in: OPTIONS }

  def permitted
    %w[ee_assess_required].freeze
  end
end
