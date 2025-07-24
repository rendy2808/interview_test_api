require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let!(:user1) { create(:user, email: 'rendy@mail.com') }
  let!(:user2) { create(:user, email: 'rendy@bois.com') }

  describe '#index' do
    context 'when all' do
      before do
        get :index
      end

      it 'returns all users' do
        expect(response).to have_http_status(:success)

        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(2)
      end
    end
  end

  describe '#show' do
    context 'when user exists' do
      before do
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
        get :show, params: { id: 999999 }
      end

      it 'returns not found status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#create' do
    context 'with valid attributes' do
      let(:valid_attributes) { { user: { name: 'Test User', email: 'test@mail.com', phone: '1234567890' } } }

      before do
        post :create, params: valid_attributes
      end

      it 'creates a new user' do
        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)
        expect(json_response['name']).to eq('Test User')
        expect(json_response['email']).to eq('test@mail.com')
      end
    end

    context 'with invalid attributes (blank)' do
      let(:invalid_attributes) { { user: { name: '', email: '', phone: '' } } }

      before do
        post :create, params: invalid_attributes
      end

      it 'does not create a new user' do
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Name can't be blank")
        expect(json_response['errors']).to include("Email can't be blank")
        expect(json_response['errors']). to include("Phone can't be blank")
      end
    end

    context 'with invalid attrinbutes (email format)' do
      let(:invalid_attributes) { { user: { name: 'Invalid Email', email: 'invalidemail', phone: '1234567890' } } }

      before do
        post :create, params: invalid_attributes
      end

      it 'does not create a new user' do
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('Email is invalid')
      end
    end
  end

  describe '#update' do
    context 'when user exists and valid attributes' do
      let(:valid_attributes) { { id: user1.id, user: { name: 'Updated Name', email: 'updated@mail.com', phone: '0987654321' } } }

      before do
        put :update, params: valid_attributes
      end

      it 'updates the user' do
        expect(response).to have_http_status(:success)

        json_response = JSON.parse(response.body)
        expect(json_response['name']).to eq('Updated Name')
        expect(json_response['email']).to eq('updated@mail.com')
        expect(json_response['phone']).to eq('0987654321')
      end
    end

    context 'when user does not exist' do
      before do
        put :update, params: { id: 999999, user: { name: 'Updated Name' } }
      end

      it 'returns not found status' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with invalid attributes' do
      let(:invalid_attributes) { { id: user1.id, user: { name: '', email: '', phone: '' } } }

      before do
        put :update, params: invalid_attributes
      end

      it 'does not update the user' do
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Name can't be blank")
        expect(json_response['errors']).to include("Email can't be blank")
        expect(json_response['errors']).to include("Phone can't be blank")
      end
    end
  end

  describe '#destroy' do
    context 'when user exists' do
      before do
        delete :destroy, params: { id: user1.id }
      end

      it 'deletes the user' do
        expect(response).to have_http_status(:no_content)
        expect(User.exists?(user1.id)).to be_falsey
      end
    end

    context 'when user does not exist' do
      before do
        delete :destroy, params: { id: 999999 }
      end

      it 'returns not found status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end