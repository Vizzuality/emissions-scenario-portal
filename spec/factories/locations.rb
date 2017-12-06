FactoryBot.define do
  factory :location do
    sequence(:name) { |n| "Country #{n}" }
    sequence(:iso_code) { |n| ('AA'..'ZZ').to_a[n] }
    region false
  end
end
