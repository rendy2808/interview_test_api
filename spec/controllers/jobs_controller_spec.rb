require 'rails_helper'

RSpec.describe Api::V1::JobsController, type: :controller do
  let!(:user1) { create(:user, email: 'rendy@mail.com') }
  let!(:user2) { create(:user, email: 'rendy@bois.com') }
  let!(:job1) { create(:job, user: user1) }
  let!(:job2) { create(:job, user: user2) }

  describe '#index' do
    context 'when all' do
      before do
        get :index
      end

      it 'returns all jobs' do
        expect(response).to have_http_status(:success)

        json_response = JSON.parse(response.body)

        expect(json_response.size).to eq(2)
      end
    end

    context 'when user_id is provided' do
      before do
        get :index, params: { user_id: user1.id }
      end

      it 'returns jobs for the specified user' do
        expect(response).to have_http_status(:success)

        json_response = JSON.parse(response.body)

        expect(json_response.size).to eq(1)
        expect(json_response.first['user_id']).to eq(user1.id)
      end
    end
  end

  describe '#show' do
    context 'when job exists' do
      before do
        get :show, params: { id: job1.id }
      end

      it 'returns the job' do
        expect(response).to have_http_status(:success)

        json_response = JSON.parse(response.body)

        expect(json_response['id']).to eq(job1.id)
      end
    end

    context 'when job does not exist' do
      before do
        get :show, params: { id: 999999 }
      end

      it 'returns not found status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#create' do
    context 'with valid attributes' do
      let(:valid_attributes) { { job: { title: 'Test', description: 'Test Desc', status: 'pending', user_id: user1.id } } }

      before do
        post :create, params: valid_attributes
      end

      it 'creates a new job' do
        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)

        expect(json_response['title']).to eq('Test')
        expect(json_response['user_id']).to eq(user1.id)
      end
    end

    context 'with invalid attributes (all)' do
      let(:invalid_attributes) { { job: { title: '', description: '', status: nil, user_id: nil } } }

      before do
        post :create, params: invalid_attributes
      end

      it 'does not create a new job' do
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)

        expect(json_response['errors']).to include("Title can't be blank")
        expect(json_response['errors']).to include("Description can't be blank")
        expect(json_response['errors']).to include("Status can't be blank")
        expect(json_response['errors']).to include("User must exist")
      end
    end

    context 'with invalid attributes (status)' do
      let(:invalid_attributes) { { job: { title: 'Test', description: 'Test Desc', status: 'none', user_id: user1.id } } }

      before do
        post :create, params: invalid_attributes
      end

      it 'does not create a new job' do
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)

        expect(json_response['errors']).to include("Status is not included in the list")
      end
    end
  end

  describe '#update' do
    context 'when job exists and valid attributes' do
      let(:valid_attributes) { { id: job1.id, job: { title: 'Updated Title', description: 'Updated Desc', status: 'completed' } } }

      before do
        put :update, params: valid_attributes
      end

      it 'updates the job' do
        expect(response).to have_http_status(:success)

        json_response = JSON.parse(response.body)

        expect(json_response['title']).to eq('Updated Title')
        expect(json_response['status']).to eq('completed')
      end
    end

    context 'when job does not exist' do
      before do
        put :update, params: { id: 999999, job: { title: 'Updated Title' } }
      end

      it 'returns not found status' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with invalid attributes (all)' do
      let(:invalid_attributes) { { id: job1.id, job: { title: '', description: '', status: nil, user_id: nil } } }

      before do
        put :update, params: invalid_attributes
      end

      it 'does not update the job' do
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)

        expect(json_response['errors']).to include("Title can't be blank")
        expect(json_response['errors']).to include("Description can't be blank")
        expect(json_response['errors']).to include("Status can't be blank")
        expect(json_response['errors']).to include("User must exist")
      end
    end

    context 'with invalid attributes (status)' do
      let(:invalid_attributes) { { id: job1.id, job: { title: 'Test', description: 'Test Desc', status: 'none' } } }

      before do
        put :update, params: invalid_attributes
      end

      it 'does not update the job' do
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)

        expect(json_response['errors']).to include("Status is not included in the list")
      end
    end
  end

  describe '#destroy' do
    context 'when job exists' do
      before do
        delete :destroy, params: { id: job1.id }
      end

      it 'deletes the job' do
        expect(response).to have_http_status(:no_content)

        expect(Job.exists?(job1.id)).to be_falsey
      end
    end

    context 'when job does not exist' do
      before do
        delete :destroy, params: { id: 999999 }
      end

      it 'returns not found status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end