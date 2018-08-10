require 'rails_helper'

RSpec.describe LinkPolicy do
  let(:user) { User.new }

  subject { described_class }

  permissions :create? do
    it {is_expected.to permit(:user, Link)}
    it {is_expected.not_to permit(nil, Link)}
  end

end
