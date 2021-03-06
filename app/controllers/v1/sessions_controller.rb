# frozen_string_literal: true

module V1
  class SessionsController < DeviseTokenAuth::SessionsController
    # rubocop:disable Rails/LexicallyScopedActionFilter
    skip_before_action :verify_authenticity_token, only: :create
    # rubocop:enable Rails/LexicallyScopedActionFilter
    respond_to :json

    private

    def respond_with(resource, _opts = {})
      render json: resource
    end

    def respond_to_on_destroy
      head :no_content
    end
  end
end
