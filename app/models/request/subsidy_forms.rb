class Request::SubsidyForms < Request
  validates :other_form, presence: { if: ->(o) { o.subsidy_forms.include?("other") } }, length: { maximum: 255 }

  def select_form_options
    SUBSIDY_FORM_OPTIONS.map do |id|
      OpenStruct.new(id: id, name: I18n.t(id&.to_sym, scope: [:subsidy_form_options]))
    end
  end

  def permitted
    [:other_form, { subsidy_forms: [] }].freeze
  end
end
