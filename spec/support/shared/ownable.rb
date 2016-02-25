shared_examples 'ownable' do |model|
  let(:object) { create(model) }

  describe '#owned_by?' do
    subject { object.owned_by?(user) }

    context 'when owned by the owner' do
      let(:user) { object.owner }
      it { is_expected.to be true }
    end

    context 'with owned by another user' do
      let(:user) { create(:user) }
      it { is_expected.to be false }
    end
  end
end
