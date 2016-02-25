require 'rails_helper'

describe Rune do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { create :rune; is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to have_many(:powers).dependent(:destroy) }
  end

  it_behaves_like 'ownable', :power
end
