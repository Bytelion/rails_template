# frozen_string_literal: true

module V1
  class RegistrationsController < DeviseTokenAuth::RegistrationsController
    # rubocop:disable Rails/LexicallyScopedActionFilter
    skip_before_action :verify_authenticity_token, only: %i[create update omniauth]
    before_action :configure_sign_up_params, only: [:create]
    before_action :configure_update_params, only: [:update]
    before_action :validate_account_update_params, only: [:update]
    # rubocop:enable Rails/LexicallyScopedActionFilter

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity

    # POST /auth
    def create
      build_resource

      if @resource.blank?
        raise DeviseTokenAuth::Errors::NoResourceDefinedError,
              "#{self.class.name} #build_resource does not define @resource,"\
              ' execution stopped.'
      end

      # give redirect value from params priority
      @redirect_url = params.fetch(
        :confirm_success_url,
        DeviseTokenAuth.default_confirm_success_url
      )

      # success redirect url is required
      return render_create_error_missing_confirm_success_url if confirmable_enabled? && !@redirect_url

      # if whitelist is set, validate redirect_url against whitelist
      return render_create_error_redirect_url_not_allowed if blacklisted_redirect_url?(@redirect_url)

      # override email confirmation, must be sent manually from ctrl
      callback_name = defined?(ActiveRecord) && resource_class < ActiveRecord::Base ? :commit : :create
      resource_class.set_callback(callback_name, :after, :send_on_create_confirmation_instructions)
      resource_class.skip_callback(callback_name, :after, :send_on_create_confirmation_instructions)

      if @resource.respond_to? :skip_confirmation_notification!
        # Fix duplicate e-mails by disabling Devise confirmation e-mail
        @resource.skip_confirmation_notification!
      end

      @resource.username = User.generate_username(@resource.first_name, @resource.last_name) if @resource.username.nil?

      if @resource.save
        yield @resource if block_given?

        unless @resource.confirmed?
          # user will require email authentication
          @resource.send_confirmation_instructions({
                                                     client_config: params[:config_name],
                                                     redirect_url: @redirect_url
                                                   })
        end

        if active_for_authentication?
          # email auth has been bypassed, authenticate user
          @token = @resource.create_token
          @resource.save!
          update_auth_header
        end

        render_create_success
      else
        clean_up_passwords @resource
        render_create_error
      end
    end

    # PUT /auth
    def omniauth
      if params['provider'] == 'google' && google_auth?(params['auth_token'])
        @resource = resource_class.from_google(params)
        if @resource
          if @resource.username.nil?
            @resource.username = User.generate_username(@resource.first_name, @resource.last_name)
          end
          @token = @resource.create_token
          @resource.save

          sign_in(:user, @resource, store: false, bypass: false)

          yield @resource if block_given?

          render_create_success
        else
          render_create_error_bad_credentials
        end
      elsif params['provider'] == 'facebook'
        facebook_response = facebook_auth(params['auth_token'])
        facebook_response['provider'] = params['provider']
        @resource = resource_class.from_facebook(facebook_response) if facebook_response['id'].present?

        if @resource
          if @resource.username.nil?
            @resource.username = User.generate_username(@resource.first_name, @resource.last_name)
          end
          @token = @resource.create_token
          @resource.save

          sign_in(:user, @resource, store: false, bypass: false)

          yield @resource if block_given?

          render_create_success
        else
          render_create_error_bad_credentials
        end
      elsif params['provider'] == 'apple'
        apple_response = apple_auth(params['fullName'], params['user'], params['identityToken'])

        @resource = nil
        # POST /auth
        # give redirect value from params priority
        # success redirect url is required
        # if whitelist is set, validate redirect_url against whitelist
        # override email confirmation, must be sent manually from ctrl
        # Fix duplicate e-mails by disabling Devise confirmation e-mail
        # user will require email authentication
        # email auth has been bypassed, authenticate user
        # PUT /auth
        @resource = resource_class.from_apple(apple_response) if apple_response && apple_response['id'].present?

        if @resource
          if @resource.username.nil?
            @resource.username = User.generate_username(@resource.first_name, @resource.last_name)
          end
          @token = @resource.create_token
          @resource.save

          sign_in(:user, @resource, store: false, bypass: false)

          yield @resource if block_given?

          render_create_success
        else
          render_create_error_bad_credentials
        end
      else
        json_response({ status: 'failure', message: ErrorMessage.provider_unauthorized }, :unauthorized)
      end
    end

    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/PerceivedComplexity

    private

    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name username])
    end

    def configure_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: %i[email first_name last_name username])
    end

    # Used to ensure the user is a member of google
    def google_auth?(access_token)
      response = HTTParty.get(
        'https://www.googleapis.com/oauth2/v3/userinfo',
        headers: { 'Authorization' => "Bearer #{access_token}" }
      )
      if response['sub'] == params['uid'] && response['email'] == params['email']
        true
      else
        false
      end
    end

    # Used to ensure the user is a member of facebook
    def facebook_auth(access_token)
      response = HTTParty.get(
        'https://graph.facebook.com/v3.2/me?fields=id%2Cemail%2Cfirst_name%2C' \
          "last_name%2Cpicture&access_token=#{access_token}",
        headers: { 'Authorization' => "Bearer #{access_token}" }
      )
      JSON.parse(response.to_json)
    end

    # Used to check if identity token from Apple is valid
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    def apple_auth(full_name, user_id, identity_token)
      response_hash = nil

      # Get cert with public keys from Apple to verify identy token
      apple_public_key_response = Net::HTTP.get(URI.parse('https://appleid.apple.com/auth/keys'))
      apple_public_certificate = JSON.parse(apple_public_key_response)

      # Determine alg used to encode identityToken
      header_segment = JSON.parse(Base64.decode64(identity_token.split('.').first))
      alg = header_segment['alg']

      begin
        # Apple provides 3 public keys for verification
        # The identitiy tokens we receive from Apple seem to verify randomly with one of the 3 public keys
        # JWT.decode() is being used to verify identityToken against public key from Apple
        # JWT.decode() throws when identity token is not valid and or not verified with public key

        # apple_key_index is used to iterate through the public keys sent by Apple
        apple_key_index ||= 0
        # prep Apple public key for use with JWT.decode()
        apple_public_key_hash = ActiveSupport::HashWithIndifferentAccess.new(
          apple_public_certificate['keys'][apple_key_index]
        )
        apple_public_jwk = JWT::JWK.import(apple_public_key_hash)

        # JWT.decode decodes identityToken and verifies identity token against public key from Apple
        # - throws if identityToken is not valid/verified or expired
        token_data ||= ::JWT.decode(identity_token, apple_public_jwk.public_key, true, { algorithm: alg })[0]

        # Double check that Apple user id matches user id in decoded identity token
        if token_data.key?('sub') && token_data.key?('email') && user_id == token_data['sub']
          # Add fields to decoded identity token needed to create Argo user
          token_data['provider'] = 'apple'
          token_data['id'] = user_id
          name_json = JSON.parse(full_name)
          token_data['last_name'] = name_json['familyName']
          token_data['first_name'] = name_json['givenName']

          response_hash = token_data
        end
      rescue StandardError => e
        # Iterate verification process through 3 public keys from Apple if needed
        retry if (apple_key_index += 1) < 3
        logger.info e
      end
      response_hash
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity

    def render_create_error_bad_credentials
      render_error(401, I18n.t('devise_token_auth.sessions.bad_credentials'))
    end
  end
end
