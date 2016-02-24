require 'rails_helper'

describe 'Api::V1::Users' do
  let!(:admin) { create :user, :admin }

  describe 'GET /api/users' do
    context 'when not authenticated' do
      it_behaves_like 'render_unauthorized' do
        def action() get api_users_path end
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
      it_behaves_like 'render_unauthorized' do
        def action() get api_user_path existing_user end
      end
    end

    context 'when authenticated' do
      context 'when the user does not exist' do
        before do
          get api_user_path(id: User.maximum(:id).next),
              nil,
              authorization: token_header(admin)
        end

        it { expect(response).to be_not_found }
        it { expect(response).to match_response_schema 'not_found' }
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
      it_behaves_like 'render_unauthorized' do
        def action() get token_api_users_path end
      end
    end

    context 'when authenticated' do
      let!(:admin) { create :user, :admin, password: 'passssssword' }

      context 'with incorrect credentials' do
        it_behaves_like 'render_unauthorized' do
          def action()
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
      it_behaves_like 'render_unauthorized' do
        def action()
          patch api_user_path(admin), { user: { username: 'new-name' } }
        end
      end
    end

    context 'when authenticated' do
      context 'when the user does not exist' do
        before do
          patch api_user_path(id: User.maximum(:id).next),
                nil,
                authorization: token_header(admin)
        end

        it { expect(response).to be_not_found }
        it { expect(response).to match_response_schema 'not_found' }
      end

      context 'when the user exists' do
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
          before do
            patch api_user_path(admin),
                  { user: { username: '' } },
                  authorization: token_header(admin)
          end

          it { expect(response).to be_unprocessable }
        end

        context 'when supplying an invalid password' do
          before do
            patch api_user_path(admin),
                  { user: { password: nil } },
                  authorization: token_header(admin)
          end

          it { expect(response).to be_unprocessable }
        end
      end

      context 'when non admin' do
        let!(:not_admin_user) { create :user }


        context 'when updating another user' do
          let!(:another_user) { create :user }
          before do
            delete api_user_path(another_user),
                   nil,
                   authorization: token_header(not_admin_user)
          end

          it { expect(response).to be_forbidden }
          it { expect(response).to match_response_schema 'forbidden' }
        end
      end
    end
  end

  describe 'DELETE /api/users/:id' do
    context 'when not authenticated' do
      it_behaves_like 'render_unauthorized' do
        def action() get token_api_users_path end
      end
    end

    context 'when authenticated' do
      context 'when the user does not exist' do
        before do
          delete api_user_path(id: User.maximum(:id).next),
                 nil,
                 authorization: token_header(admin)
        end

        it { expect(response).to be_not_found }
        it { expect(response).to match_response_schema 'not_found' }
      end

      context 'when the user exists' do
        before do
          delete api_user_path(admin),
                 nil,
                 authorization: token_header(admin)
        end

        it { expect(response.status).to eq 204 }
        it { expect(response.message).to eq 'No Content' }
        it { expect(User.find_by id: admin.id).to be_nil }
      end

      context 'when non admin' do
        let!(:not_admin_user) { create :user }

        context 'when deleting another user' do
          let!(:another_user) { create :user }
          before do
            delete api_user_path(another_user),
                   nil,
                   authorization: token_header(not_admin_user)
          end

          it { expect(response).to be_forbidden }
          it { expect(response).to match_response_schema 'forbidden' }
        end
      end
    end
  end
end
