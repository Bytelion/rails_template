# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  # Association tests

  # Validation tests
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:username) }
end
