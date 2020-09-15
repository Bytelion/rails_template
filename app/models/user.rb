# frozen_string_literal: true
class User < ActiveRecord::Base
  devise :database_authenticatable, :confirmable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  # Validations
  # Email presence is not validated to handle Facebook accounts with
  # phone numbers only
  validates_presence_of :first_name, :last_name, :username
  validates_uniqueness_of :email, :username

  # Attributes
  attribute :full_name, default: ''

  # Actions
  after_initialize :set_full_name

  after_create { |user|
    if user.admin?
      user.skip_confirmation!
      user.send_reset_password_instructions
    end
  }

  def set_full_name
    self.full_name = "#{self.first_name} #{self.last_name}"
  end

  def password_required?
    new_record? ? false : super
  end

  def self.from_google(auth)
    temp_user = where(email: auth['email']).first
    if temp_user.blank? || temp_user.provider == auth['provider']
      get_omniauth_user(
        uid: auth['uid'],
        provider: auth['provider'],
        email: auth['email'],
        password: Devise.friendly_token[0,20],
        first_name: auth['first_name'],
        last_name: auth['last_name'],
        image: auth['image']
      )
    else
      temp_user.errors.add(:email, "has already been taken")
      raise ActiveRecord::RecordInvalid.new(temp_user)
    end
  end

  def self.from_facebook(auth)
    temp_user = where(email: auth['email']).first
    if temp_user.blank? || temp_user.provider == auth['provider']
      get_omniauth_user(
        uid: auth['id'],
        provider: auth['provider'],
        email: auth['email'],
        password: Devise.friendly_token[0,20],
        first_name: auth['first_name'],
        last_name: auth['last_name'],
        image: auth['picture']['data']['url']
      )
    else
      temp_user.errors.add(:email, "has already been taken")
      raise ActiveRecord::RecordInvalid.new(temp_user)
    end
  end

  def self.from_apple(auth)
    temp_user = where(email: auth['email']).first
    if temp_user.blank? || temp_user.provider == auth['provider']
      get_omniauth_user(
        uid: auth['id'],
        provider: auth['provider'],
        email: auth['email'],
        password: Devise.friendly_token[0,20],
        first_name: auth['first_name'],
        last_name: auth['last_name']
      )
    else
      temp_user.errors.add(:email, "has already been taken")
      raise ActiveRecord::RecordInvalid.new(temp_user)
    end
  end

  def self.get_omniauth_user(user_params)
    user = find_by(provider: user_params[:provider], uid: user_params[:uid])
    is_new_user = user.nil?
    user = User.create(
      uid: user_params[:uid],
      provider: user_params[:provider],
      email: user_params[:email],
      password: Devise.friendly_token[0,20],
      first_name: user_params[:first_name],
      last_name: user_params[:last_name],
      image: user_params.key?(:image) ? user_params[:image] : ""
    ) if is_new_user
    user.skip_confirmation! if is_new_user

    user
  end

  def self.generate_username(first_name,last_name)
    username = "#{first_name}_#{last_name}".parameterize(separator: '_')
    username = get_unique_username(username)
  end

  def self.get_unique_username(username)
    taken_usernames = User.where("username LIKE ?", "#{username}%").pluck(:username)
    puts taken_usernames.to_json
    return username if ! taken_usernames.include?(username)

    for i in 2..(taken_usernames.count+2)
      new_username = "#{username}_#{i}"
      return new_username if ! taken_usernames.include?(new_username)
    end
  end
end
