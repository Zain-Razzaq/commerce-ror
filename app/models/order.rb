class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  validates :user_id, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending approved] }
  validates :shipping_address, length: { minimum: 5, maximum: 255 }
  enum :status, { pending: 0, approved: 1 }, default: :pending
end