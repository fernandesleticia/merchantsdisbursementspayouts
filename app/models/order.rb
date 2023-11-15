# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :merchant

  validates :uid,
    presence: true,
    uniqueness: true
end
