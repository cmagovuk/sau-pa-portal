prawn_document do |pdf|
  pdf.text t('layouts.original_submission.heading', type: scheme_subsidy_name(@request)), align: :center, size: 18, style: :bold
  pdf.text @request.reference_number, align: :center, size: 18, style: :bold
  pdf.move_down 20

  pdf_output_field(pdf, "Referral type",t(@request.referral_type&.to_sym, scope: [:helpers, :label, :request, :referral_type_options]))
  if @request.previous_refno
    pdf_output_field(pdf, "Previously submitted as", "#{@request.previous_refno} (#{@request.previous_status})")
  end

  if @request.referral_type == "call"
    pdf_header(pdf, "Called in by Secretary of State")
    pdf_output_field(pdf, 'Call in direction document', @request.call_in.attached? ? @request.call_in.filename.to_s : nil)
    pdf_output_field(pdf, 'Date of direction', formatted_date(@request.direction_date))
    pdf_output_field(pdf, 'Direction relates to', t(@request.call_in_type&.to_sym, scope: [:helpers, :label, :request, :call_in_type_options]))
  end

  if @request.referral_type == "par"
    pdf_header(pdf, "Post-award referral")
    pdf_output_field(pdf, 'Referral document', (@request.call_in.attached? ? @request.call_in.filename.to_s : nil))
    pdf_output_field(pdf, 'Date of direction', formatted_date(@request.direction_date))
    pdf_output_field(pdf, 'Entered on BEIS database', @request.par_on_td.present? ? t(@request.par_on_td&.to_sym, scope: [:helpers, :label, :request, :par_on_td_options]) : nil)

    if @request.par_on_td == "y"
      pdf_output_field(pdf, 'BEIS database reference number', @request.par_td_ref_no)
    end
  end

  if @request.scheme_subsidy == "scheme"
    pdf_header(pdf, "Subsidy scheme characteristics")
    pdf_output_field(pdf, 'Subsidy scheme name', @request.scheme_name)
    pdf_output_field(pdf, 'Public Authority name', @request.public_authority.pa_name)
    pdf_output_field(pdf, 'Amount budgeted for scheme', @request.budget.present? ? "£#{format_numeric(@request, :budget)}" : nil)
    pdf_output_field(pdf, 'Maximum amount that can be given', @request.max_amt.present? ? "£#{format_numeric(@request, :max_amt)}" : nil)
    pdf_output_field(pdf, 'Does scheme relate to goods or services', translate_terms(@request.ben_good_svr, "helpers.label.request.ben_good_svr_options").join("\n"))
    pdf_output_field(pdf, 'Locations', translate_terms(@request.location, "helpers.label.request.location_options").join("\n"))
    pdf_output_field(pdf, 'Additional location information', @request.other_loc)
    pdf_output_field(pdf, 'Sectors', translate_terms(@request.sectors, "helpers.label.request.sectors_options").join("\n"))
    pdf_output_field(pdf, 'Description', @request.description)
    pdf_output_field(pdf, 'Description is non-confidential', @request.is_nc.present? ? @request.is_nc.humanize : nil )
    
    if (@request.is_nc == "no")
      pdf_output_field(pdf, 'Non-confidential description', @request.nc_description)
    end

    pdf_output_field(pdf, 'Legal basis', @request.legal)
    pdf_output_field(pdf, 'Policy objective', @request.policy)

    pdf_output_field(pdf, 'Purposes', translate_terms(@request.purposes, "helpers.label.request.purposes_options").join("\n"))
    if @request.purposes.present? && @request.purposes.include?("other")
      pdf_output_field(pdf, 'Description of other purpose', @request.other_purpose)
    end
    pdf_output_field(pdf, 'Decision confirmation date', @request.confirm_date.present? ? formatted_date(@request.confirm_date) : nil)
    pdf_output_field(pdf, 'Start date', @request.start_date.present? ? formatted_date(@request.start_date) : nil)
    pdf_output_field(pdf, 'End date', @request.end_date.present? ? formatted_date(@request.end_date) : nil)
  end

  if @request.scheme_subsidy == "subsidy"
    pdf_header(pdf, "Subsidy characteristics")
    pdf_output_field(pdf, 'Public Authority name', @request.public_authority.pa_name)
    pdf_output_field(pdf, 'Subsidy form', @request.subsidy_form.present? ? t(@request.subsidy_form&.to_sym, scope: [:subsidy_form_options]) : nil)

    if @request.subsidy_form == "other"
        pdf_output_field(pdf, 'Other form', @request.other_form)
    end

    if @request.subsidy_form != "tax"
        pdf_output_field(pdf, 'Award amount', @request.budget.present? ? "£#{format_numeric(@request, :budget)}" : nil)
    else
        pdf_output_field(pdf, 'Tax award range', @request.tax_amt.present? ? tax_amount_output(@request) : nil)
    end

    pdf_output_field(pdf, 'Award confirmation date', @request.confirm_date.present? ? formatted_date(@request.confirm_date) : nil)
    pdf_output_field(pdf, 'Beneficiary ID type', @request.ben_id_type.present? ? t(@request.ben_id_type&.to_sym, scope: "helpers.label.request.ben_id_type_options") : "")
    pdf_output_field(pdf, 'Beneficiary ID', @request.ben_id)
    pdf_output_field(pdf, 'Beneficiary name', @request.beneficiary)
    pdf_output_field(pdf, 'Beneficiary size', @request.ben_size.present? ? t(@request.ben_size&.to_sym, scope: "helpers.label.request.ben_size_options") : "") 
    pdf_output_field(pdf, 'Does subsidy relate to goods or services', translate_terms(@request.ben_good_svr, "helpers.label.request.ben_good_svr_options").join("\n"))
    pdf_output_field(pdf, 'Location of spend', translate_terms(@request.location, "helpers.label.request.location_options").join("\n"))
    pdf_output_field(pdf, 'Additional location information', @request.other_loc)
    pdf_output_field(pdf, 'Sector', translate_terms(@request.sectors, "helpers.label.request.sectors_options").join("\n"))
    pdf_output_field(pdf, 'Description', @request.description)
    pdf_output_field(pdf, 'Description is non-confidential', @request.is_nc.present? ? @request.is_nc.humanize : nil )
    
    if (@request.is_nc == "no")
      pdf_output_field(pdf, 'Non-confidential description', @request.nc_description)
    end

    pdf_output_field(pdf, 'Legal basis', @request.legal)
    pdf_output_field(pdf, 'Policy objective', @request.policy)

    pdf_output_field(pdf, 'Purpose', translate_terms(@request.purposes, "helpers.label.request.purposes_options").join("\n"))

    if @request.purposes.present? && @request.purposes.include?("other")
        pdf_output_field(pdf, 'Description of other purpose', @request.other_purpose)
    end
  end

  unless @request.referral_type == "par" || (@request.referral_type == "call" && @request.call_in_type == "other")
    pdf_header(pdf, "Why the #{scheme_subsidy_name(@request).downcase} meets the characteristics of a #{referral_type_shortname(@request)}")
    pdf_output_field(pdf, 'Description', @request.character_desc)
    docs = []
    @request.character_desc_docs.each do |d|
      docs += [d.filename]
    end

    pdf_output_field(pdf, 'Supporting documents', docs.join("\n"))
  end

  if @request.referral_type == "par"
    pdf_header(pdf, "Post-award referral assessment")
    pdf_output_field(pdf, 'Was assessment carried out', @request.par_assessed.present? ? t(@request.par_assessed&.to_sym, scope: [:helpers, :label, :request, :par_assessed_options]) : nil)

    if @request.par_assessed == "n"
        pdf_output_field(pdf, 'Why was assessment not carried out', @request.par_reason)
    end
  end

  if @request.referral_type != "par" || @request.par_assessed == "y"
    pdf_header(pdf, "Assessment of compliance")
    pdf_output_field(pdf, 'Energy and Environment assessment carried out', @request.ee_assess_required.present? ? t(@request.ee_assess_required&.to_sym, scope: [:helpers, :label, :request, :ee_assess_required_options]) : nil)

    pdf_output_field(pdf, "Chapter 2 prohibitions and requirements", @request.is_c2_relevant.present? ? t(@request.is_c2_relevant&.to_sym, scope: [:helpers, :label, :request, :is_c2_relevant_options]) : nil)
      
    if (@request.is_c2_relevant == "y")
      pdf_output_field(pdf, "Chapter 2 details", @request.c2_description)
    end

    docs = []
    @request.assessment_docs.each do |d|
      docs += [d.filename]
    end

    pdf_output_field(pdf, 'Supporting evidence', docs.join("\n"))

    pdf_header(pdf, "Assessment of compliance with the subsidy control principles")
    pdf_output_field(pdf, 'Principle A', @request.assess_pa)
    pdf_output_field(pdf, 'Principle B', @request.assess_pb)
    pdf_output_field(pdf, 'Principle C', @request.assess_pc)
    pdf_output_field(pdf, 'Principle D', @request.assess_pd)
    pdf_output_field(pdf, 'Principle E', @request.assess_pe)
    pdf_output_field(pdf, 'Principle F', @request.assess_pf)
    pdf_output_field(pdf, 'Principle G', @request.assess_pg)

    if @request.ee_assess_required == "y"
      pdf_header(pdf, "Assessment of compliance with the energy and environment principles")
      pdf_output_field(pdf, 'Principle A', @request.assess_ee_pa)
      pdf_output_field(pdf, 'Principle B', @request.assess_ee_pb)
      pdf_output_field(pdf, 'Principle C', @request.assess_ee_pc)
      pdf_output_field(pdf, 'Principle D', @request.assess_ee_pd)
      pdf_output_field(pdf, 'Principle E', @request.assess_ee_pe)
      pdf_output_field(pdf, 'Principle F', @request.assess_ee_pf)
      pdf_output_field(pdf, 'Principle G', @request.assess_ee_pg)
      pdf_output_field(pdf, 'Principle H', @request.assess_ee_ph)
      pdf_output_field(pdf, 'Principle I', @request.assess_ee_pi)
    end
  end
end
