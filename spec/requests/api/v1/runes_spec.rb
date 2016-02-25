require 'rails_helper'

describe 'Api::V1::Runes' do
  let(:admin) { create(:user, :admin) }

  describe 'GET /api/runes' do
    context 'when not authenticated' do
      it_behaves_like 'render unauthorized' do
        def action
          get api_runes_path
        end
      end
    end

    context 'when authenticated' do
      let!(:runes) { create_list :rune, 2 }
      before { get api_runes_path, nil, authorization: token_header(admin) }

      it { expect(response).to be_ok }
      it { expect(response).to match_response_schema 'runes' }

      it 'shows all the runes' do
        expect(json_response.map { |u| u[:name] }).to eq runes.map(&:name)
      end
    end
  end

  describe 'GET /api/runes/:id' do
    let!(:existing_rune) { create :rune }

    context 'when not authenticated' do
      it_behaves_like 'render unauthorized' do
        def action
          get api_rune_path(existing_rune)
        end
      end
    end

    context 'when authenticated' do
      context 'when the rune does not exist' do
        it_behaves_like 'render not found' do
          def action
            get api_rune_path(id: Rune.maximum(:id).next),
              nil,
              authorization: token_header(admin)
          end
        end
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
  end

  describe 'POST /api/runes' do
    context 'when not authenticated' do
      it_behaves_like 'render unauthorized' do
        def action
          post api_runes_path, { rune: { name: 'new-name' } }
        end
      end
    end

    context 'when authenticated' do
      context 'when guest' do
        let!(:guest) { create :user, :guest }

        it_behaves_like 'render forbidden' do
          def action
            post api_runes_path,
                 { rune: { name: 'new-name' } },
                 authorization: token_header(guest)
          end
        end
      end

      context 'when supplying valid data' do
        before do
          post api_runes_path,
               { rune: { name: 'new-name' } },
               authorization: token_header(admin)
        end

        it { expect(response).to be_created }
        it { expect(response).to match_response_schema 'rune' }
        it { expect(json_response[:name]).to eq 'new-name' }
      end

      context 'when supplying an invalid name' do
        it_behaves_like 'render unprocessable' do
          def action
            post api_runes_path,
               { rune: { name: '' } },
               authorization: token_header(admin)
          end
        end
      end
    end
  end

  describe 'PATCH/PUT /api/runes/:id' do
    let!(:existing_rune) { create :rune }

    context 'when not authenticated' do
      it_behaves_like 'render unauthorized' do
        def action
          patch api_rune_path(existing_rune),
                { rune: { name: 'new-name' } }
        end
      end
    end

    context 'when authenticated' do
      context 'when the rune does not exist' do
        it_behaves_like 'render not found' do
          def action
            patch api_rune_path(id: Rune.maximum(:id).next),
                { rune: { name: 'new-name' } },
                authorization: token_header(admin)
          end
        end
      end

      context 'when the rune exists' do
        let(:user) { create :user }

        context 'when the rune belongs to the user' do
          let(:belonging_rune) { create :rune, user: user }

          context 'when supplying valid data' do
            before do
              patch api_rune_path(belonging_rune),
                    { rune: { name: 'new-name' } },
                    authorization: token_header(user)
            end

            it { expect(response).to be_ok }
            it { expect(response).to match_response_schema 'rune' }
            it { expect(json_response[:name]).to eq belonging_rune.reload.name }
          end

          context 'when supplying an invalid name' do
            it_behaves_like 'render unprocessable' do
              def action
                patch api_rune_path(belonging_rune),
                      { rune: { name: '' } },
                      authorization: token_header(user)
              end
            end
          end
        end

        context 'when non admin' do
          context 'when the rune belongs to another user' do
            let(:another_user_rune) { create :rune, user: create(:user) }

            it_behaves_like 'render forbidden' do
              def action
                patch api_rune_path(another_user_rune),
                       { rune: { name: 'new-name' } },
                       authorization: token_header(user)
              end
            end
          end

          context 'when the rune does not belong to a user' do
            it_behaves_like 'render forbidden' do
              def action
                delete api_rune_path(existing_rune),
                       { rune: { name: 'new-name' } },
                       authorization: token_header(user)
              end
            end
          end
        end

        context 'when admin' do
          context 'when the rune belongs to another user' do
            let(:another_user_rune) { create :rune, user: create(:user) }

            before do
              patch api_rune_path(another_user_rune),
                       { rune: { name: 'new-name' } },
                     authorization: token_header(admin)
            end

            it { expect(response).to be_ok }
            it { expect(response).to match_response_schema 'rune' }
            it { expect(json_response[:name]).to eq another_user_rune.reload.name }
          end

          context 'when the rune does not belong to a user' do
            before do
              patch api_rune_path(existing_rune),
                       { rune: { name: 'new-name' } },
                     authorization: token_header(admin)
            end

            it { expect(response).to be_ok }
            it { expect(response).to match_response_schema 'rune' }
            it { expect(json_response[:name]).to eq existing_rune.reload.name }
          end
        end
      end
    end
  end

  describe 'DELETE /api/runes/:id' do
    let!(:existing_rune) { create :rune }

    context 'when not authenticated' do
      it_behaves_like 'render unauthorized' do
        def action
          delete api_rune_path(existing_rune)
        end
      end
    end

    context 'when authenticated' do
      context 'when the rune does not exist' do
        it_behaves_like 'render not found' do
          def action
            delete api_rune_path(id: Rune.maximum(:id).next),
                 nil,
                 authorization: token_header(admin)
          end
        end
      end

      context 'when the rune exists' do
        let(:user) { create :user }

        context 'when the rune belongs to the user' do
          let(:belonging_rune) { create :rune, user: user }

          before do
            delete api_rune_path(belonging_rune),
                   nil,
                   authorization: token_header(user)
          end

          it { expect(response.status).to eq 204 }
          it { expect(response.message).to eq 'No Content' }
          it { expect(Rune.find_by id: belonging_rune.id).to be_nil }
        end

        context 'when non admin' do
          context 'when the rune belongs to another user' do
            let(:another_user_rune) { create :rune, user: create(:user) }

            it_behaves_like 'render forbidden' do
              def action
                delete api_rune_path(another_user_rune),
                       nil,
                       authorization: token_header(user)
              end
            end
          end

          context 'when the rune does not belong to a user' do
            it_behaves_like 'render forbidden' do
              def action
                delete api_rune_path(existing_rune),
                       nil,
                       authorization: token_header(user)
              end
            end
          end
        end

        context 'when admin' do
          context 'when the rune belongs to another user' do
            let(:another_user_rune) { create :rune, user: create(:user) }

            before do
              delete api_rune_path(another_user_rune),
                     nil,
                     authorization: token_header(admin)
            end

            it { expect(response.status).to eq 204 }
            it { expect(response.message).to eq 'No Content' }
            it { expect(Rune.find_by id: another_user_rune.id).to be_nil }
          end

          context 'when the rune does not belong to a user' do
            before do
              delete api_rune_path(existing_rune),
                     nil,
                     authorization: token_header(admin)
            end

            it { expect(response.status).to eq 204 }
            it { expect(response.message).to eq 'No Content' }
            it { expect(Rune.find_by id: existing_rune.id).to be_nil }
          end
        end
      end
    end
  end
end
