require 'swagger_helper'

RSpec.describe 'api/v1/notes', type: :request do
  path '/api/v1/notes' do
    get 'Retrieves all notes' do
      tags 'Notes'
      produces 'application/json'

      response '200', 'notes retrieved' do
        run_test!
      end
    end

    post 'Creates a note' do
      tags 'Notes'
      consumes 'application/json'
      parameter name: :note, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          content: { type: :string }
        },
        required: %w[title content]
      }

      response '201', 'note created' do
        let(:note) { { title: 'Test Note', content: 'This is a test note' } }
        run_test!
      end
    end
  end

  path '/api/v1/notes/{id}' do
    parameter name: :id, in: :path, type: :string, description: 'Note ID'

    get 'Retrieves a note' do
      tags 'Notes'
      produces 'application/json'

      response '200', 'note found' do
        let(:id) { '1' }
        run_test!
      end

      response '404', 'note not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end

    put 'Updates a note' do
      tags 'Notes'
      consumes 'application/json'
      parameter name: :note, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          content: { type: :string }
        }
      }

      response '200', 'note updated' do
        let(:id) { '1' }
        let(:note) { { title: 'Updated Title', content: 'Updated content' } }
        run_test!
      end
    end

    delete 'Deletes a note' do
      tags 'Notes'

      response '204', 'note deleted' do
        let(:id) { '1' }
        run_test!
      end
    end
  end
end
