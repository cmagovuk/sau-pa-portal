class PostReport::ReferralDetails < PostReport
  def permitted
    %w[referral_name].freeze
  end
end
