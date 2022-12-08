module ExportHelper
  def map_purpose(purposes)
    return "" if purposes.blank? || purposes.count.zero?

    compact_terms = purposes.select(&:present?)
    return "" if compact_terms.count.zero?

    case compact_terms[0]
    when "cultu" then "Culture or Heritage"
    when "emply" then "Employment"
    when "energ" then "Energy efficiency"
    when "envir" then "Environmental protection"
    when "infra" then "Infrastructure"
    when "regio" then "Regional development"
    when "rescu" then "Rescue aid"
    when "resea" then "Research and development"
    when "servi" then "Services of Public Economic Interest"
    when "smesm" then "SME (Small/Medium-sized enterprise) support"
    when "train" then "Training"
    when "other" then "Other"
    else ""
    end
  end

  def map_subsidy_form(subsidy_form)
    return "" if subsidy_form.blank?

    case subsidy_form
    when "dire" then "Direct Grant"
    when "equi" then "Equity"
    when "gaur" then "Guarantee"
    when "loan" then "Loan"
    when "above" then "Purchase of goods or services above market prices"
    when "below" then "Provision of goods or services below market prices"
    when "tax" then "Tax measures"
    when "other" then "Other"
    else ""
    end
  end

  def map_tax_amount(tax_amt)
    return "" if tax_amt.blank?

    case tax_amt
    when "upto_60" then "£1 - £60,000"
    when "upto_500" then "£60,001 - £500,000"
    when "upto_1000" then "£500,001 - £1,000,000"
    when "upto_2000" then "£1,000,001 - £2,000,000"
    when "upto_5000" then "£2,000,001 - £5,000,000"
    when "upto_10000" then "£5,000,001 - £10,000,000"
    when "upto_30000" then "£10,000,001 - £30,000,000"
    when "over_30000" then "£30,000,001 or more"
    else ""
    end
  end

  def map_ben_id_type(ben_id_type)
    return "" if ben_id_type.blank?

    case ben_id_type
    when "comp" then "Company Registration Number"
    when "charity" then "Charity Number"
    when "vat" then "VAT number"
    when "utr" then "UTR Number"
    else ""
    end
  end

  def map_ben_size(ben_size)
    return "" if ben_size.blank?

    case ben_size
    when "micro" then "Micro (fewer than 10 employees)"
    when "small" then "Small (between 10 and 49 employees)"
    when "medium" then "Medium (between 50 and 249 employees)"
    when "large" then "Large (more than 250 employees)"
    else ""
    end
  end

  def map_goods_services(ben_good_svr)
    return "" if ben_good_svr.blank? || ben_good_svr.count.zero?

    compact_terms = ben_good_svr.select(&:present?)
    return "" if compact_terms.count.zero?

    case compact_terms[0]
    when "goods" then "Goods"
    when "services" then "Services"
    else ""
    end
  end

  def map_locations(locations)
    return "" if locations.blank? || locations.count.zero?

    compact_terms = locations.select(&:present?)
    return "" if compact_terms.count.zero?

    case compact_terms[0]
    when "noea" then "North East"
    when "nowe" then "North West"
    when "york" then "Yorkshire and the Humber"
    when "emid" then "East Midlands"
    when "wmid" then "West Midlands"
    when "east" then "East of England"
    when "lond" then "London"
    when "soea" then "South East"
    when "sowe" then "South West"
    when "scot" then "Scotland"
    when "wales" then "Wales"
    when "ni" then "Northern Ireland"
    else ""
    end
  end

  def map_sectors(sectors)
    return "" if sectors.blank? || sectors.count.zero?

    compact_terms = sectors.select(&:present?)
    return "" if compact_terms.count.zero?

    case compact_terms[0]
    when "accom" then "Accommodation and food service activities"
    when "actex" then "Activities of extraterritorial organisations and bodies"
    when "actho" then "Activities of households as employers; undifferentiated goods- and services-producing activities of households for own use"
    when "admin" then "Administrative and support service activities"
    when "agric" then "Agriculture, forestry and fishing"
    when "artse" then "Arts, entertainment and recreation"
    when "const" then "Construction"
    when "educa" then "Education"
    when "elect" then "Electricity, gas, steam and air conditioning supply"
    when "finan" then "Financial and insurance activities"
    when "human" then "Human health and social work activities"
    when "infor" then "Information and communication"
    when "manuf" then "Manufacturing"
    when "minin" then "Mining and quarrying"
    when "other" then "Other service activities"
    when "profe" then "Professional, scientific and technical activities"
    when "publi" then "Public administration  and defence; compulsory social security"
    when "reale" then "Real estate activities"
    when "trans" then "Transportation and storage"
    when "water" then "Water supply; sewerage, waste management and remediation activities"
    when "whole" then "Wholesale and retail trade; repair of motor vehicles and motorcycles"
    else ""
    end
  end
end
