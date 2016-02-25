require 'rails_helper'

describe PowerPolicy do
  let(:rune) { create :rune, user: create(:user) }
  let(:resource) { create :power, rune: rune }
  subject { described_class }

  context 'when guest user' do
    let(:user) { create :user, :guest }

    permissions :index? do
      it { expect(subject).to permit(user, resource) }
    end

    permissions :show? do
      it { expect(subject).to permit(user, resource) }
    end

    permissions :create? do
      it { expect(subject).not_to permit(user, resource) }
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

    permissions :create? do
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

    permissions :create? do
      context "when the power's rune belongs to the user" do
        let(:rune) { create :rune, user: user }
        let(:power) { create :power, rune: rune }

        it { expect(subject).to permit(user, power) }
      end

      context "when the power's rune does not belong to the user" do
        let(:not_belonging_rune) { create :rune, powers: [create(:power)] }

        it { expect(subject).not_to permit(user, not_belonging_rune.powers.first) }
      end
    end

    permissions :update? do
      context "when the power's rune belongs to the user" do
        let(:rune) { create :rune, user: user }
        let(:power) { create :power, rune: rune }

        it { expect(subject).to permit(user, power) }
      end

      context "when the power's rune does not belong to the user" do
        let(:not_belonging_rune) { create :rune, powers: [create(:power)] }

        it { expect(subject).not_to permit(user, not_belonging_rune.powers.first) }
      end
    end

    permissions :destroy? do
      context "when the power's rune belongs to the user" do
        let(:rune) { create :rune, user: user }
        let(:power) { create :power, rune: rune }

        it { expect(subject).to permit(user, power) }
      end

      context "when the power's rune does not belong to the user" do
        let(:not_belonging_rune) { create :rune, powers: [create(:power)] }

        it { expect(subject).not_to permit(user, not_belonging_rune.powers.first) }
      end
    end
  end
end
