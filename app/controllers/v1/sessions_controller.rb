# frozen_string_literal: true

module V1
  class SessionsController < DeviseTokenAuth::SessionsController
    skip_before_action :verify_authenticity_token, only: :create
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
