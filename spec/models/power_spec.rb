require 'rails_helper'

describe Power do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { create :power; is_expected.to validate_uniqueness_of(:name).scoped_to(:rune_id) }
    it { is_expected.to belong_to(:rune) }
  end

  it { is_expected.to delegate_method(:owner).to(:rune) }
  it_behaves_like 'ownable', :power
end
