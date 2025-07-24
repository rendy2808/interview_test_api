require 'rails_helper'

RSpec.describe Api::V1::JobsController, type: :controller do
  # without saving to DB
  let(:user1) { instance_double(User, id: 1) }
  let(:user2) { instance_double(User, id: 2) }
  let(:job1) { Job.new(id: 1, title: 'Job 1', description: 'Desc 1', status: 'pending', user_id: user1.id) }
  let(:job2) { Job.new(id: 2, title: 'Job 2', description: 'Desc 2', status: 'completed', user_id: user2.id) }

  describe '#index' do
    context 'when all' do
      before do
        allow(Job).to receive(:all).and_return([job1, job2])
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
        allow(Job).to receive(:where).with(user_id: user1.id).and_return([job1])
        get :index, params: { user_id: user1.id }
      end

      it 'returns jobs for the specified user' do
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(1)
        expect(json_response.first['user_id']).to eq(user1.id)
      end
    end

    context 'when user_id provided and cached' do
      before do
        allow(Rails.cache).to receive(:fetch).with("jobs_user_id_#{user1.id}", expires_in: 10.minutes).and_return([job1])
        get :index, params: { user_id: user1.id }
      end

      it 'returns cached jobs for the specified user' do
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
        allow(Job).to receive(:find).with(job1.id).and_return(job1)
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
        allow(Job).to receive(:find).with(999999).and_raise(ActiveRecord::RecordNotFound)
        get :show, params: { id: 999999 }
      end

      it 'returns not found status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#create' do
    context 'with valid attributes' do
      let(:valid_params) { { job: { title: 'Test', description: 'Test Desc', status: 'pending', user_id: user1.id.to_s } } }
      let(:new_job) { Job.new(id: 3, title: 'Test', description: 'Test Desc', status: 'pending', user_id: user1.id) }

      before do
        allow(Job).to receive(:new).with(ActionController::Parameters.new(valid_params[:job]).permit!).and_return(new_job)
        allow(new_job).to receive(:save).and_return(true)
        post :create, params: valid_params
      end

      it 'creates a new job' do
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['title']).to eq('Test')
        expect(json_response['user_id']).to eq(user1.id)
      end
    end

    context 'with invalid attributes (all)' do
      let(:invalid_params) { { job: { title: '', description: '', status: '', user_id: '' } } }
      let(:new_job) { instance_double(Job, save: false, errors: double(full_messages: ["Title can't be blank", "Description can't be blank", "Status can't be blank", "User must exist"])) }

      before do
        allow(Job).to receive(:new).with(ActionController::Parameters.new(invalid_params[:job]).permit!).and_return(new_job)
        allow(new_job).to receive(:save).and_return(false)
        post :create, params: invalid_params
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
      let(:invalid_params) { { job: { title: 'Test', description: 'Test Desc', status: 'none', user_id: user1.id.to_s } } }
      let(:new_job) { instance_double(Job, save: false, errors: double(full_messages: ["Status is not included in the list"])) }

      before do
        allow(Job).to receive(:new).with(ActionController::Parameters.new(invalid_params[:job]).permit!).and_return(new_job)
        allow(new_job).to receive(:save).and_return(false)
        post :create, params: invalid_params
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
      let(:valid_params) { { id: job1.id, job: { title: 'Updated Title', description: 'Updated Desc', status: 'completed' } } }

      before do
        allow(Job).to receive(:find).with(job1.id).and_return(job1)
        allow(job1).to receive(:update).with(ActionController::Parameters.new(valid_params[:job]).permit!).and_return(true)
        put :update, params: valid_params
      end

      it 'updates the job' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when job does not exist' do
      before do
        allow(Job).to receive(:find).with(999999).and_raise(ActiveRecord::RecordNotFound)
        put :update, params: { id: 999999, job: { title: 'Updated Title' } }
      end

      it 'returns not found status' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with invalid attributes (all)' do
      let(:invalid_params) { { id: job1.id, job: { title: '', description: '', status: '', user_id: '' } } }

      before do
        allow(Job).to receive(:find).with(job1.id).and_return(job1)
        allow(job1).to receive(:update).with(ActionController::Parameters.new(invalid_params[:job]).permit!).and_return(false)
        allow(job1).to receive(:errors).and_return(double(full_messages: ["Title can't be blank", "Description can't be blank", "Status can't be blank", "User must exist"]))
        put :update, params: invalid_params
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
      let(:invalid_params) { { id: job1.id, job: { title: 'Test', description: 'Test Desc', status: 'none' } } }

      before do
        allow(Job).to receive(:find).with(job1.id).and_return(job1)
        allow(job1).to receive(:update).with(ActionController::Parameters.new(invalid_params[:job]).permit!).and_return(false)
        allow(job1).to receive(:errors).and_return(double(full_messages: ["Status is not included in the list"]))
        put :update, params: invalid_params
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
        allow(Job).to receive(:find).with(job1.id).and_return(job1)
        allow(job1).to receive(:destroy).and_return(true)
        delete :destroy, params: { id: job1.id }
      end

      it 'deletes the job' do
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when job does not exist' do
      before do
        allow(Job).to receive(:find).with(999999).and_raise(ActiveRecord::RecordNotFound)
        delete :destroy, params: { id: 999999 }
      end

      it 'returns not found status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end