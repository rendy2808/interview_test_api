FactoryBot.define do
  factory :job do
    title { "The Job" }
    description { "test desc" }
    status { "pending" }
    association :user
  end
end