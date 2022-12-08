class Request::Review < Request
  validate :validate_test_confirm

  attr_accessor :confirm_answers

  def validate_test_confirm
    errors.add :confirm_answers, I18n.t("errors.attributes.confirm_answers.not_confirmed") unless confirm_answers == "1"
  end

  def permitted
    %w[confirm_answers].freeze
  end
end
