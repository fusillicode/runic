require 'rails_helper'

describe UserPolicy do
  let(:resource) { create :user }
  subject { described_class }

  context 'when guest user' do
    let(:user) { create :user, :guest }

    permissions :index? do
      it { expect(subject).to permit(user, resource) }
    end

    permissions :show? do
      it { expect(subject).to permit(user, resource) }
    end

    permissions :update? do
      it { expect(subject).not_to permit(user, resource) }
    end

    permissions :destroy? do
      it { expect(subject).not_to permit(user, resource) }
    end
  end

  context 'when admin user' do
    let(:user) { create :user, :admin }

    permissions :index? do
      it { expect(subject).to permit(user, resource) }
    end

    permissions :show? do
      it { expect(subject).to permit(user, resource) }
    end

    permissions :update? do
      it { expect(subject).to permit(user, resource) }
    end

    permissions :destroy? do
      it { expect(subject).to permit(user, resource) }
    end
  end

  context 'when regular user' do
    let(:user) { create :user }

    permissions :index? do
      it { expect(subject).to permit(user, resource) }
    end

    permissions :show? do
      it { expect(subject).to permit(user, resource) }
    end

    permissions :update? do
      context 'when updating themselves' do
        it { expect(subject).to permit(user, user) }
      end

      context 'when updating another user' do
        it { expect(subject).not_to permit(user, resource) }
      end
    end

    permissions :destroy? do
      context 'when destroying themselves' do
        it { expect(subject).to permit(user, user) }
      end

      context 'when destroying another user' do
        it { expect(subject).not_to permit(user, resource) }
      end
    end
  end
end
