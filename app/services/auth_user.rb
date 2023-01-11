class AuthUser
  attr_reader :name, :email, :id

  def initialize(request)
    @name = "Not given"
    @email = "Not given"
    @roles = []
    @id = "Not given"
    @user = nil

    aad_token = request.headers["HTTP_X_MS_TOKEN_AAD_ID_TOKEN"]

    if aad_token.present?
      decoded_token = JWT.decode aad_token, nil, false
      @email = decoded_token[0]["email"]
      @roles = decoded_token[0]["roles"]
      @name = decoded_token[0]["name"]
      @id = decoded_token[0]["oid"]
    elsif !Rails.env.production?
      @email = ENV["DEV_EMAIL"]
      @roles = as_array(ENV["DEV_ROLE"])
      @name = ENV["DEV_NAME"]
      @id = ENV["DEV_OID"]
    end

    if has_role?("SAU-PA-SU") || has_role?("SAU-PA-U")
      @user = User.find_by(oid: id)
    end
  end

  def has_role?(role)
    @roles.include?(role_mappings[role])
  end

  def is_authorised?
    @user.present? || has_role?("SAU-Casework") || has_role?("SAU-Pipeline") || has_role?("SAU-Admin")
  end

  def is_pa_user?
    has_role?("SAU-PA-SU") || has_role?("SAU-PA-U")
  end

  def is_sau_user?
    has_role?("SAU-Casework") || has_role?("SAU-Pipeline") || has_role?("SAU-Admin")
  end

  def case_access?(case_id)
    return false if case_id.blank?

    UserService.new.has_case_access(@id, case_id) == true
  end

  def can_access_request?(request)
    return false unless is_pa_user? && request.present?

    request.public_authority_id == pa_id
  end

  def pa_name
    @pa_name ||= @user.public_authority.pa_name if @user.present? && @user.public_authority.present?
  end

  def pa_id
    @user.public_authority.id if @user.present? && @user.public_authority.present?
  end

  def user_id
    @user.id if @user.present?
  end

private

  def role_mappings
    @role_mappings ||= Rails.application.config.role_mappings
  end

  def as_array(stringified_array)
    stringified_array.delete_prefix("[").delete_suffix("]").split(%r{,\s*}).map { |r| r.delete_prefix('"').delete_suffix('"') }
  end
end
