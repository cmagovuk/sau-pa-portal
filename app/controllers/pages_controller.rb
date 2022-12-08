require "pp"

class PagesController < ApplicationController
  def show
    @decoded_token_print = "No token found"
    @decoded_cp_print = "No token found"

    aad_token = request.headers["HTTP_X_MS_TOKEN_AAD_ID_TOKEN"]

    if aad_token.present?
      decoded_token = JWT.decode aad_token, nil, false
      @decoded_token_print = decoded_token.pretty_inspect
    end

    render template: "pages/#{params[:page]}"
  end
end
