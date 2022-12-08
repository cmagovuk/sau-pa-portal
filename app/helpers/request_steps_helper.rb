module RequestStepsHelper
  def referral_type_fullname(request)
    return "Unknown referral type" if request.referral_type.blank?

    return t(request.referral_type&.to_sym, scope: %i[referral_type long]) unless request.referral_type == "call"

    return "Unknown call-in type" if request.call_in_type.blank?

    t(request.call_in_type&.to_sym, scope: %i[referral_type long])
  end

  def referral_type_shortname(request)
    return "unknown referral type" if request.referral_type.blank?

    return t(request.referral_type&.to_sym, scope: %i[referral_type short]) unless request.referral_type == "call"

    t(request.call_in_type&.to_sym, scope: %i[referral_type short])
  end

  def scheme_subsidy_name(request)
    return t(request.scheme_subsidy&.to_sym, scope: [:scheme_subsidy]) if request.scheme_subsidy.present?

    ""
  end

  def translate_terms(terms, translation_scope)
    compact_terms = terms.select(&:present?)
    compact_terms.map { |t| I18n.t "#{translation_scope}.#{t}" }
  end

  def translate_first_term(terms, translation_scope)
    compact_terms = terms.select(&:present?)
    I18n.t "#{translation_scope}.#{compact_terms[0]}"
  end

  def formatted_date(date)
    date.present? ? date.strftime("%d %B %Y") : nil
  end

  def format_numeric(request, field)
    return nil if request.errors[field].count.positive? || request.send(field).blank?

    request.send(field).to_i == request.send(field) ? request.send(field).to_i : sprintf("%.2f", request.send(field))
  end
end
