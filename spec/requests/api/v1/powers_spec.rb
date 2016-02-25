require 'rails_helper'

describe 'Api::V1::Powers' do
  let(:admin) { create(:user, :admin) }

  describe 'GET /api/runes/:rune_id/powers' do
    let(:rune) { create :rune }
    let!(:rune_powers) { create_list :power, 2, rune: rune }
    let!(:powers_of_another_rune) { create_list :power, 2 }

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

      it 'does not show other runes powers' do
        rune_powers_ids = json_response.map { |p| p[:id] }
        powers_of_another_rune.each do |power_of_another_rune|
          expect(rune_powers_ids).not_to include power_of_another_rune.id
        end
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
                power: { name: 'new-name' }
        end
      end
    end

    context 'when authenticated' do
      context 'when the power does not exist' do
        it_behaves_like 'render not found' do
          def action
            patch api_power_path(id: Power.maximum(:id).next),
                { power: { name: 'new-name' } },
                authorization: token_header(admin)
          end
        end
      end

      context 'when the power exists' do
        let(:user) { create :user }

        context 'when the power belongs to a rune owned by the user' do
          let(:power_of_owned_rune) { create :power, rune: create(:rune, user: user) }

          context 'when supplying valid data' do
            before do
              patch api_power_path(power_of_owned_rune),
                    { power: { name: 'new-name' } },
                    authorization: token_header(user)
            end

            it { expect(response).to be_ok }
            it { expect(response).to match_response_schema 'rune' }
            it { expect(json_response[:name]).to eq power_of_owned_rune.reload.name }
          end

          context 'when supplying an invalid name' do
            it_behaves_like 'render unprocessable' do
              def action
                patch api_power_path(power_of_owned_rune),
                    { power: { name: '' } },
                    authorization: token_header(user)
              end
            end
          end
        end

        context 'when non admin' do
          context 'when the power belongs to a rune owned by another user' do
            let(:power_of_another_user_rune) do
              create :power, rune: create(:rune, user: create(:user))
            end

            it_behaves_like 'render forbidden' do
              def action
                patch api_power_path(power_of_another_user_rune),
                      nil,
                      authorization: token_header(user)
              end
            end
          end

          context 'when the power rune does not belong to a user' do
            it_behaves_like 'render forbidden' do
              def action
                patch api_power_path(existing_power),
                       { power: { name: 'new-name' } },
                       authorization: token_header(user)
              end
            end
          end
        end

        context 'when admin' do
          context 'when the power belongs to a rune owned by another user' do
            let(:power_of_another_user_rune) do
              create :power, rune: create(:rune, user: create(:user))
            end

            before do
              patch api_power_path(power_of_another_user_rune),
                       { power: { name: 'new-name' } },
                     authorization: token_header(admin)
            end

            it { expect(response).to be_ok }
            it { expect(response).to match_response_schema 'power' }
            it { expect(json_response[:name]).to eq power_of_another_user_rune.reload.name }
          end

          context 'when the power rune does not belong to a user' do
            before do
              patch api_power_path(existing_power),
                       { power: { name: 'new-name' } },
                     authorization: token_header(admin)
            end

            it { expect(response).to be_ok }
            it { expect(response).to match_response_schema 'power' }
            it { expect(json_response[:name]).to eq existing_power.reload.name }
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
        let(:user) { create :user }

        context 'when the power belongs to a rune owned by the user' do
          let(:power_of_owned_rune) { create :power, rune: create(:rune, user: user) }

          before do
            delete api_power_path(power_of_owned_rune),
                  nil,
                  authorization: token_header(user)
          end

          it { expect(response.status).to eq 204 }
          it { expect(response.message).to eq 'No Content' }
          it { expect(Power.find_by id: power_of_owned_rune.id).to be_nil }
        end

        context 'when non admin' do
          context 'when the power belongs to a rune owned by another user' do
            let(:power_of_another_user_rune) do
              create :power, rune: create(:rune, user: create(:user))
            end

            it_behaves_like 'render forbidden' do
              def action
                delete api_power_path(power_of_another_user_rune),
                      nil,
                      authorization: token_header(user)
              end
            end
          end

          context 'when the power rune does not belong to a user' do
            it_behaves_like 'render forbidden' do
              def action
                delete api_power_path(existing_power),
                       nil,
                       authorization: token_header(user)
              end
            end
          end
        end

        context 'when admin' do
          context 'when the power belongs to a rune owned by another user' do
            let(:power_of_another_user_rune) do
              create :power, rune: create(:rune, user: create(:user))
            end

            before do
              delete api_power_path(power_of_another_user_rune),
                       nil,
                     authorization: token_header(admin)
            end

            it { expect(response.status).to eq 204 }
            it { expect(response.message).to eq 'No Content' }
            it { expect(Power.find_by id: power_of_another_user_rune.id).to be_nil }
          end

          context 'when the power rune does not belong to a user' do
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
end
