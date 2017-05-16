class Scenario < ApplicationRecord
  belongs_to :model
  has_many :time_series_values, dependent: :destroy
end
