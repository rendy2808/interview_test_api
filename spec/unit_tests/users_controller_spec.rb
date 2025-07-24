require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  # without saving to DB
  let(:user1) { User.new(id: 1, name: 'Rendy Test', email: 'rendy@mail.com', phone: '1234567890') }
  let(:user2) { User.new(id: 2, name: 'Bois Test', email: 'rendy@bois.com', phone: '0987654321') }

  describe '#index' do
    before do
      allow(User).to receive(:all).and_return([user1, user2])
      get :index
    end

    it 'returns all users' do
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(2)
    end
  end

  describe '#show' do
    context 'when user exists' do
      before do
        allow(User).to receive(:find).with(user1.id.to_s).and_return(user1)
        get :show, params: { id: user1.id }
      end

      it 'returns the user' do
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(user1.id)
      end
    end

    context 'when user does not exist' do
      before do
        allow(User).to receive(:find).with('999999').and_raise(ActiveRecord::RecordNotFound)
        get :show, params: { id: 999999 }
      end

      it 'returns not found status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#create' do
    context 'with valid attributes' do
      let(:valid_params) { { user: { name: 'Test User', email: 'test@mail.com', phone: '1234567890' } } }
      let(:new_user) { User.new(id: 3, name: 'Test User', email: 'test@mail.com', phone: '1234567890') }

      before do
        allow(User).to receive(:new).with(ActionController::Parameters.new(valid_params[:user]).permit!).and_return(new_user)
        allow(new_user).to receive(:save).and_return(true)
        post :create, params: valid_params
      end

      it 'creates a new user' do
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['name']).to eq('Test User')
        expect(json_response['email']).to eq('test@mail.com')
      end
    end

    context 'with invalid attributes (blank)' do
      let(:invalid_params) { { user: { name: '', email: '', phone: '' } } }
      let(:new_user) { instance_double(User, save: false, errors: double(full_messages: ["Name can't be blank", "Email can't be blank", "Phone can't be blank"])) }

      before do
        allow(User).to receive(:new).with(ActionController::Parameters.new(invalid_params[:user]).permit!).and_return(new_user)
        allow(new_user).to receive(:save).and_return(false)
        post :create, params: invalid_params
      end

      it 'does not create a new user' do
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Name can't be blank")
        expect(json_response['errors']).to include("Email can't be blank")
        expect(json_response['errors']).to include("Phone can't be blank")
      end
    end

    context 'with invalid attributes (email format)' do
      let(:invalid_email_params) { { user: { name: 'Test User', email: 'invalid_email', phone: '1234567890' } } }
      let(:new_user) { instance_double(User, save: false, errors: double(full_messages: ["Email is invalid"])) }

      before do
        allow(User).to receive(:new).with(ActionController::Parameters.new(invalid_email_params[:user]).permit!).and_return(new_user)
        allow(new_user).to receive(:save).and_return(false)
        post :create, params: invalid_email_params
      end

      it 'does not create a new user' do
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Email is invalid")
      end
    end
  end

  describe '#update' do
    context 'when user exists and valid attributes' do
      let(:valid_params) { { id: user1.id, user: { name: 'Updated Name', email: 'updated@mail.com', phone: '0987654321' } } }

      before do
        allow(User).to receive(:find).with(user1.id.to_s).and_return(user1)
        allow(user1).to receive(:update).with(ActionController::Parameters.new(valid_params[:user]).permit!).and_return(true)
        put :update, params: valid_params
      end

      it 'updates the user' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user does not exist' do
      before do
        allow(User).to receive(:find).with('999999').and_raise(ActiveRecord::RecordNotFound)
        put :update, params: { id: 999999, user: { name: 'Updated Name' } }
      end

      it 'returns not found status' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with invalid attributes' do
      let(:invalid_params) { { id: user1.id, user: { name: '', email: '', phone: '' } } }

      before do
        allow(User).to receive(:find).with(user1.id.to_s).and_return(user1)
        allow(user1).to receive(:update).with(ActionController::Parameters.new(invalid_params[:user]).permit!).and_return(false)
        allow(user1).to receive(:errors).and_return(double(full_messages: ["Name can't be blank", "Email can't be blank", "Phone can't be blank"]))
        put :update, params: invalid_params
      end

      it 'does not update the user' do
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Name can't be blank")
        expect(json_response['errors']). to include("Email can't be blank")
        expect(json_response['errors']). to include("Phone can't be blank")
      end
    end
  end

  describe '#destroy' do
    context 'when user exists' do
      before do
        allow(User).to receive(:find).with(user1.id.to_s).and_return(user1)
        allow(user1).to receive(:destroy).and_return(true)
        delete :destroy, params: { id: user1.id }
      end

      it 'deletes the user' do
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when user does not exist' do
      before do
        allow(User).to receive(:find).with('999999').and_raise(ActiveRecord::RecordNotFound)
        delete :destroy, params: { id: 999999 }
      end

      it 'returns not found status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end