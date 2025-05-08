class SunHistory < ApplicationRecord
  validates :city, :date, presence: true
  validates :date, uniqueness: { scope: :city }
end
