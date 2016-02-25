require 'rails_helper'

describe 'Api::V1::Powers' do
  let(:admin) { create(:user, :admin) }

  describe 'GET /api/runes/:rune_id/powers' do
    let(:rune) { create :rune }
    let!(:rune_powers) { create_list :power, 2, rune: rune }
    let(:another_rune) { create :rune }
    let!(:another_rune_powers) { create_list :power, 2, rune: another_rune }

    context 'when not authenticated' do
      it_behaves_like 'render unauthorized' do
        def action
          get api_rune_powers_path rune
        end
      end
    end

    context 'when authenticated' do
      before { get api_rune_powers_path(rune), nil, authorization: token_header(admin) }

      it { expect(response).to be_ok }
      it { expect(response).to match_response_schema 'powers' }

      it 'shows all the rune powers' do
        expect(json_response.map { |p| p[:id] }).to eq rune_powers.map(&:id)
      end

      it 'does not show powers of other runes' do
        expect(json_response.map { |p| p[:id] }).not_to eq another_rune_powers.map(&:id)
      end
    end
  end

  describe 'GET /api/powers/:id' do
    let!(:existing_power) { create :power }

    context 'when not authenticated' do
      it_behaves_like 'render unauthorized' do
        def action
          get api_power_path existing_power
        end
      end
    end

    context 'when authenticated' do
      context 'when the power does not exist' do
        it_behaves_like 'render not found' do
          def action
            get api_power_path(id: Power.maximum(:id).next),
              nil,
              authorization: token_header(admin)
          end
        end
      end

      context 'when the power exists' do
        before do
          get api_power_path(existing_power),
              nil,
              authorization: token_header(admin)
        end

        it { expect(response).to be_ok }
        it { expect(response).to match_response_schema 'power' }

        it 'shows the power' do
          expect(json_response[:id]).to eq existing_power.id
        end
      end
    end
  end

  describe 'POST /api/runes/:rune_id/powers' do
    let(:rune) { create :rune }

    context 'when not authenticated' do
      it_behaves_like 'render unauthorized' do
        def action
          post api_rune_powers_path(rune), { power: { name: 'new-name' } }
        end
      end
    end

    context 'when authenticated' do
      context 'when guest' do
        let(:guest) { create :user, :guest }

        it_behaves_like 'render forbidden' do
          def action
            post api_rune_powers_path(rune),
                 { power: { name: 'new-name' } },
                 authorization: token_header(guest)
          end
        end
      end

      context 'when supplying valid data' do
        before do
          post api_rune_powers_path(rune),
               { power: { name: 'new-name' } },
               authorization: token_header(admin)
        end

        it { expect(response).to be_created }
        it { expect(response).to match_response_schema 'rune' }
        it { expect(json_response[:name]).to eq 'new-name' }
      end

      context 'when supplying an invalid name' do
        it_behaves_like 'render unprocessable' do
          def action
            post api_rune_powers_path(rune),
               { power: { name: '' } },
               authorization: token_header(admin)
          end
        end
      end
    end
  end

  describe 'PATCH/PUT /api/powers/:id' do
    let!(:existing_power) { create :power }

    context 'when not authenticated' do
      it_behaves_like 'render unauthorized' do
        def action
          patch api_power_path(existing_power),
                rune: { name: 'new-name' }
        end
      end
    end

    context 'when authenticated' do
      context 'when the power does not exist' do
        it_behaves_like 'render not found' do
          def action
            patch api_power_path(id: Power.maximum(:id).next),
                nil,
                authorization: token_header(admin)
          end
        end
      end

      context 'when the power exists' do
        context 'when non admin and the power is from another user rune' do
          let(:non_admin) { create :user }
          let(:another_user) { create :user }
          let(:another_user_rune) { create :rune, user: another_user }
          let!(:another_user_rune_power) { create :power, rune: another_user_rune }

          it_behaves_like 'render forbidden' do
            def action
              patch api_power_path(another_user_rune_power),
                    nil,
                    authorization: token_header(non_admin)
            end
          end
        end

        context 'when supplying valid data' do
          before do
            patch api_power_path(existing_power),
                  { power: { name: 'new-name' } },
                  authorization: token_header(admin)
          end

          it { expect(response).to be_ok }
          it { expect(response).to match_response_schema 'rune' }
          it { expect(json_response[:name]).to eq existing_power.reload.name }
        end

        context 'when supplying an invalid name' do
          it_behaves_like 'render unprocessable' do
            def action
              patch api_power_path(existing_power),
                  { power: { name: '' } },
                  authorization: token_header(admin)
            end
          end
        end
      end
    end
  end

  describe 'DELETE /api/powers/:id' do
    let!(:existing_power) { create :power }

    context 'when not authenticated' do
      it_behaves_like 'render unauthorized' do
        def action
          delete api_power_path(existing_power)
        end
      end
    end

    context 'when authenticated' do
      context 'when the power does not exist' do
        it_behaves_like 'render not found' do
          def action
            delete api_power_path(id: Power.maximum(:id).next),
                 nil,
                 authorization: token_header(admin)
          end
        end
      end

      context 'when the power exists' do
        context 'when non admin and the power is from another user rune' do
          let(:non_admin) { create :user }
          let(:another_user) { create :user }
          let(:another_user_rune) { create :rune, user: another_user }
          let!(:another_user_rune_power) { create :power, rune: another_user_rune }

          it_behaves_like 'render forbidden' do
            def action
              delete api_power_path(another_user_rune_power),
                     nil,
                     authorization: token_header(non_admin)
            end
          end
        end

        context 'when the power is from the user rune' do
          before do
            delete api_power_path(existing_power),
                   nil,
                   authorization: token_header(admin)
          end

          it { expect(response.status).to eq 204 }
          it { expect(response.message).to eq 'No Content' }
          it { expect(Power.find_by id: existing_power.id).to be_nil }
        end
      end
    end
  end
end
