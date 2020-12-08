# frozen_string_literal: true

module V1
  class PasswordsController < DeviseTokenAuth::PasswordsController
    # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action :validate_redirect_url_param, only: %i[create edit]
    skip_before_action :verify_authenticity_token, only: %i[create edit update]
    # rubocop:enable Rails/LexicallyScopedActionFilter

    private

    def validate_redirect_url_param
      # give redirect value from params priority
      @redirect_url = params.fetch(
        :redirect_url,
        DeviseTokenAuth.default_password_reset_url
      )

      return render_create_error_missing_redirect_url unless @redirect_url
    end
  end
end
