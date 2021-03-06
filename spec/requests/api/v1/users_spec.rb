require 'rails_helper'

describe 'Api::V1::Users' do
  let!(:admin) { create :user, :admin }

  describe 'GET /api/users' do
    context 'when not authenticated' do
      it_behaves_like 'render unauthorized' do
        def action
          get api_users_path
        end
      end
    end

    context 'when authenticated' do
      let!(:users) { create_list :user, 2 }
      before do
        get api_users_path,
            nil,
            authorization: token_header(admin)
      end

      it { expect(response).to be_ok }
      it { expect(response).to match_response_schema 'users' }

      it 'shows the users' do
        expect(json_response.map { |u| u[:username] }).to eq users.map(&:username)
      end

      it 'does not show the requesting user' do
        expect(json_response.map { |u| u[:username] }).not_to include admin.username
      end
    end
  end

  describe 'GET /api/users/:id' do
    let!(:existing_user) { create :user }

    context 'when not authenticated' do
      it_behaves_like 'render unauthorized' do
        def action
          get api_user_path(existing_user)
        end
      end
    end

    context 'when authenticated' do
      context 'when the user does not exist' do
        it_behaves_like 'render not found' do
          def action
            get api_user_path(id: User.maximum(:id).next),
                nil,
                authorization: token_header(admin)
          end
        end
      end

      context 'when the user exists' do
        before do
          get api_user_path(existing_user),
              nil,
              authorization: token_header(admin)
        end

        it { expect(response).to be_ok }
        it { expect(response).to match_response_schema 'user' }

        it 'shows the user' do
          expect(json_response[:username]).to eq existing_user.username
        end
      end
    end
  end

  describe 'GET /api/token' do
    context 'when not authenticated' do
      it_behaves_like 'render unauthorized' do
        def action
          get token_api_users_path
        end
      end
    end

    context 'when authenticated' do
      let!(:admin) { create :user, :admin, password: 'passssssword' }

      context 'with incorrect credentials' do
        it_behaves_like 'render unauthorized' do
          def action
            get token_api_users_path,
                nil,
                'HTTP_AUTHORIZATION' => encode_credentials(admin.username, 'ops')
          end
        end
      end

      context 'with correct credentials' do
        before do
          get token_api_users_path,
              nil,
              'HTTP_AUTHORIZATION' => encode_credentials(admin.username, 'passssssword')
        end

        it { expect(response).to be_ok }
        it { expect(response).to match_response_schema 'token' }
      end
    end
  end

  describe 'PATCH/PUT /api/users/:id' do
    context 'when not authenticated' do
      it_behaves_like 'render unauthorized' do
        def action
          patch api_user_path(admin), user: { username: 'new-name' }
        end
      end
    end

    context 'when authenticated' do
      context 'when the user does not exist' do
        it_behaves_like 'render not found' do
          def action
            patch api_user_path(id: User.maximum(:id).next),
                  nil,
                  authorization: token_header(admin)
          end
        end
      end

      context 'when the user exists' do
        context 'when non admin' do
          let!(:non_admin_user) { create :user }

          context 'when the user is not the authenticated one' do
            let!(:another_user) { create :user }

            it_behaves_like 'render forbidden' do
              def action
                patch api_user_path(another_user),
                      nil,
                      authorization: token_header(non_admin_user)
              end
            end
          end
        end

        context 'when supplying valid data' do
          before do
            patch api_user_path(admin),
                  { user: { username: 'new-name' } },
                  authorization: token_header(admin)
          end

          it { expect(response).to be_ok }
          it { expect(response).to match_response_schema 'user' }
          it { expect(json_response[:username]).to eq admin.reload.username }
        end

        context 'when supplying an invalid username' do
          it_behaves_like 'render unprocessable' do
            def action
              patch api_user_path(admin),
                    { user: { username: '' } },
                    authorization: token_header(admin)
            end
          end
        end

        context 'when supplying an invalid password' do
          it_behaves_like 'render unprocessable' do
            def action
              patch api_user_path(admin),
                    { user: { password: nil } },
                    authorization: token_header(admin)
            end
          end
        end
      end
    end
  end

  describe 'DELETE /api/users/:id' do
    context 'when not authenticated' do
      it_behaves_like 'render unauthorized' do
        def action
          delete api_user_path(admin)
        end
      end
    end

    context 'when authenticated' do
      context 'when the user does not exist' do
        it_behaves_like 'render not found' do
          def action
            delete api_user_path(id: User.maximum(:id).next),
                   nil,
                   authorization: token_header(admin)
          end
        end
      end

      context 'when the user exists' do
        context 'when non admin' do
          let!(:non_admin_user) { create :user }

          context 'when the user is not the authenticated one' do
            let!(:another_user) { create :user }

            it_behaves_like 'render forbidden' do
              def action
                delete api_user_path(another_user),
                       nil,
                       authorization: token_header(non_admin_user)
              end
            end
          end
        end

        context 'when the user is the authenticated one' do
          before do
            delete api_user_path(admin),
                   nil,
                   authorization: token_header(admin)
          end

          it { expect(response.status).to eq 204 }
          it { expect(response.message).to eq 'No Content' }
          it { expect(User.find_by(id: admin.id)).to be_nil }
        end
      end
    end
  end
end
