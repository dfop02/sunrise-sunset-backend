class SunHistory < ApplicationRecord
  validates :city, :date, :sunrise, :sunset, presence: true
  validates :date, uniqueness: { scope: :city }
end
