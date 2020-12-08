# frozen_string_literal: true

class ErrorMessage
  def self.param_missing(param)
    "Missing param(s): #{param}"
  end

  def self.unauthorized_user
    'User is unauthorized to make this request'
  end

  def self.provider_unauthorized
    'The user could not be logged in, invalid auth_token response'
  end

  def self.admin_unauthorized
    'You must be an admin to login!'
  end
end
