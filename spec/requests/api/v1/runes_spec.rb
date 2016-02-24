require 'rails_helper'

describe 'Api::V1::Runes' do
  let(:admin) { create(:user, :admin) }

  describe 'GET /api/runes' do
    let!(:runes) { create_list :rune, 2 }
    before { get api_runes_path, nil, authorization: token_header(admin) }

    it { expect(response).to be_ok }
    it { expect(response).to match_response_schema 'runes' }

    it 'shows all the runes' do
      expect(json_response.map { |u| u[:name] }).to eq runes.map(&:name)
    end
  end

  describe 'GET /api/runes/:id' do
    let!(:existing_rune) { create :rune }

    context 'when the rune does not exist' do
      before do
        get api_rune_path(id: Rune.maximum(:id).next),
            nil,
            authorization: token_header(admin)
      end

      it { expect(response).to be_not_found }
      it { expect(response).to match_response_schema 'not_found' }
    end

    context 'when the rune exists' do
      before do
        get api_rune_path(existing_rune),
            nil,
            authorization: token_header(admin)
      end

      it { expect(response).to be_ok }
      it { expect(response).to match_response_schema 'rune' }

      it 'shows the rune' do
        expect(json_response[:name]).to eq existing_rune.name
      end
    end
  end

  describe 'PATCH/PUT /api/runes/:id' do
    let!(:existing_rune) { create :rune }

    context 'when the rune does not exist' do
      before do
        patch api_rune_path(id: Rune.maximum(:id).next),
              nil,
              authorization: token_header(admin)
      end

      it { expect(response).to be_not_found }
      it { expect(response).to match_response_schema 'not_found' }
    end

    context 'when the rune exists' do
      context 'when supplying valid data' do
        before do
          patch api_rune_path(existing_rune),
                { rune: { name: 'new-name' } },
                authorization: token_header(admin)
        end

        it { expect(response).to be_ok }
        it { expect(response).to match_response_schema 'rune' }
        it { expect(json_response[:name]).to eq existing_rune.reload.name }
      end

      context 'when supplying an invalid runename' do
        before do
          patch api_rune_path(existing_rune),
                { rune: { name: '' } },
                authorization: token_header(admin)
        end

        it { expect(response).to be_unprocessable }
      end
    end

    context 'when non admin' do
      let!(:user) { create :user }

      context 'when updating another user rune' do
        let!(:another_user_rune) { create :rune, user: create(:user) }
        before do
          delete api_rune_path(another_user_rune),
                 nil,
                 authorization: token_header(user)
        end

        it { expect(response).to be_forbidden }
        it { expect(response).to match_response_schema 'forbidden' }
      end
    end
  end

  describe 'DELETE /api/runes/:id' do
    let!(:existing_rune) { create :rune }

    context 'when the rune does not exist' do
      before do
        delete api_rune_path(id: Rune.maximum(:id).next),
               nil,
               authorization: token_header(admin)
      end

      it { expect(response).to be_not_found }
      it { expect(response).to match_response_schema 'not_found' }
    end

    context 'when the rune exists' do
      before do
        delete api_rune_path(existing_rune),
               nil,
               authorization: token_header(admin)
      end

      it { expect(response.status).to eq 204 }
      it { expect(response.message).to eq 'No Content' }
      it { expect(Rune.find_by id: existing_rune.id).to be_nil }
    end

    context 'when non admin' do
      let!(:user) { create :user }

      context 'when deleting another user rune' do
        let!(:another_user_rune) { create :rune, user: create(:user) }
        before do
          delete api_rune_path(another_user_rune), nil, authorization: token_header(user)
        end

        it { expect(response).to be_forbidden }
        it { expect(response).to match_response_schema 'forbidden' }
      end
    end
  end
end