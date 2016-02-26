require 'rails_helper'

describe User do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:username) }
    it { create :user; is_expected.to validate_uniqueness_of(:username) }
    it { is_expected.to have_secure_password }

    context 'on a new user' do
      it 'should not be valid without a password' do
        expect(build(:user, password: nil)).not_to be_valid
      end

      it 'should not be valid with a short password' do
        expect(build(:user, password: 'short')).not_to be_valid
      end
    end

    context 'on an existing user' do
      let(:subject) { create :user }

      it { expect(subject).to be_valid }

      it 'should not be valid with an empty password' do
        subject.password = nil
        expect(subject).not_to be_valid
      end

      it 'should be valid with a new (valid) password' do
        subject.password = 'new password'
        expect(subject).to be_valid
      end
    end
  end

  describe '#owns?' do
    let(:resource) { double }

    context 'when the user owns the resource' do
      before { allow(resource).to receive(:owned_by?).with(subject) { true } }
      it { expect(subject.owns?(resource)).to be true }
    end

    context 'when the user does not own the resource' do
      before { allow(resource).to receive(:owned_by?).with(subject) { false } }
      it { expect(subject.owns?(resource)).to be false }
    end

    context 'when the resource is not ownable' do
      it { expect(subject.owns?(resource)).to be false }
    end
  end
end
