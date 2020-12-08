# frozen_string_literal: true

class DeviseMailer < Devise::Mailer
  default from: 'ENTER NAME HERE Team <no-reply@example.domain>'
  def confirmation_instructions(record, token, opts = {})
    opts[:subject] = 'Welcome to ENTER NAME HERE!'
    super
  end
end
