require 'swagger_helper'

RSpec.describe 'api/v1/users', type: :request do
  path '/api/v1/users' do
    get 'Retrieves all users' do
      tags 'Users'
      produces 'application/json'

      response '200', 'users retrieved' do
        run_test!
      end
    end

    post 'Creates a user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string },
          password: { type: :string }
        },
        required: %w[name email password]
      }

      response '201', 'user created' do
        let(:user) { { name: 'John Doe', email: 'john@example.com', password: 'password' } }
        run_test!
      end
    end
  end

  path '/api/v1/users/{id}' do
    parameter name: :id, in: :path, type: :string, description: 'User ID'

    get 'Retrieves a user' do
      tags 'Users'
      produces 'application/json'

      response '200', 'user found' do
        let(:id) { '1' }
        run_test!
      end

      response '404', 'user not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end

    put 'Updates a user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string }
        }
      }

      response '200', 'user updated' do
        let(:id) { '1' }
        let(:user) { { name: 'Updated Name', email: 'updated@example.com' } }
        run_test!
      end
    end

    delete 'Deletes a user' do
      tags 'Users'

      response '204', 'user deleted' do
        let(:id) { '1' }
        run_test!
      end
    end
  end
end
