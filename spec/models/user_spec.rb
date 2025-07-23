require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:jobs).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:phone) }
    it { should validate_uniqueness_of(:email) }
    
    context 'email format' do
      it 'should allow valid email formats' do
        valid_emails = ['rendy@rendytest.com', 'rendy.test@rendytest.com', 'rendy+plus@rendytest.co.uk']
        valid_emails.each do |email|
          user = User.new(name: 'Rendy Test', email: email, phone: '1234567890')
          expect(user).to be_valid
        end
      end

      it 'should not allow invalid email formats' do
        invalid_emails = ['rendy@', '@rendytest.com', 'rendy.rendytest.com']
        invalid_emails.each do |email|
          user = User.new(name: 'Rendy Test', email: email, phone: '1234567890')
          expect(user).not_to be_valid
          expect(user.errors[:email]).to include('is invalid')
        end
      end
    end
  end
end