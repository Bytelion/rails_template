# frozen_string_literal: true

require 'acceptance_helper'

resource 'Authentication' do
  # Headers that will be sent in every request.
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  post '/auth' do
    let(:user) { build(:user) }

    let(:request) do
      { email: user.email, password: 'password',
        username: user.username, first_name: user.first_name,
        last_name: user.last_name }
    end
    example 'Signing up a User' do
      do_request(request)
      expect(json['status']).to eq('success')
      expect(json['data'].to_json).to eq(json_item(User.last))
      expect(status).to eq(200)
    end
  end

  post '/auth/sign_in' do
    let!(:user) { create(:user, password: 'password') }

    let(:request) { { email: user.email, password: 'password' } }
    example 'Signing in a User' do
      do_request(request)
      expect(json['data']['id']).to eq(User.last.id)
      expect(json['data']['email']).to eq(User.last.email)
      expect(json['data']['provider']).to eq(User.last.provider)
      expect(json['data']['first_name']).to eq(User.last.first_name)
      expect(json['data']['last_name']).to eq(User.last.last_name)
      expect(json['data']['username']).to eq(User.last.username)
      expect(json['data']['admin']).to eq(false)
      expect(status).to eq(200)
    end
  end

  post '/auth/password' do
    let!(:user) { create(:user) }

    let(:request) { { email: user.email, redirect_url: 'https://example.domain/auth/password' } }
    example 'Requesting a password reset' do
      do_request(request)
      expect(json['success']).to eq(true)
      expect(status).to eq(200)
    end
  end

  put '/auth/password' do
    let!(:user) { create(:user) }
    let(:auth_headers) { user.create_new_auth_token }
    let!(:uid) { auth_headers['uid'] }
    let!(:client_id) { auth_headers['client'] }
    let!(:access_token) { auth_headers['access-token'] }

    header 'uid', :uid
    header 'client', :client_id
    header 'access-token', :access_token

    let(:request) { { password: 'password', password_confirmation: 'password' } }
    example 'Reset the password for the user' do
      do_request(request)
      expect(json['success']).to eq(true)
      expect(status).to eq(200)
    end
  end

  put '/auth/password' do
    let!(:user) { create(:user) }
    let(:auth_headers) { user.create_new_auth_token }
    let!(:uid) { auth_headers['uid'] }
    let!(:client_id) { auth_headers['client'] }
    let!(:access_token) { auth_headers['access-token'] }

    header 'uid', :uid
    header 'client', :client_id
    header 'access-token', :access_token

    let(:request) { { password: 'password', password_confirmation: 'password' } }
    example 'Reset the password for the user' do
      do_request(request)
      expect(json['success']).to eq(true)
      expect(status).to eq(200)
    end
  end

  # Adding these tests in to show what fields are required
  # Tests will always be expected to fail without a proper token
  post '/auth/google/sign_in' do
    let(:user) { build(:user) }

    let(:request) do
      { auth_token: Devise.friendly_token[0, 20], email: user.email,
        first_name: user.first_name, last_name: user.last_name,
        image: user.image }
    end
    example 'Sign in the User with google' do
      do_request(request)
      expect(json['status']).to eq('failure')
      expect(status).to eq(401)
    end
  end

  post '/auth/facebook/sign_in' do
    let(:user) { build(:user) }

    let(:request) { { auth_token: Devise.friendly_token[0, 20] } }
    example 'Sign in the User with facebook' do
      do_request(request)
      expect(json['success']).to eq(false)
      expect(status).to eq(401)
    end
  end

  post '/auth/apple/sign_in' do
    let(:user) { build(:user) }

    let(:request) do
      { fullName: { first_name: user.first_name,
                    last_name: user.last_name },
        user: user.uid,
        identityToken: apple_test_token }
    end
    example 'Sign in the User with apple' do
      do_request(request)
      expect(json['success']).to eq(false)
      expect(status).to eq(401)
    end
  end
end
