class Product < ApplicationRecord
  belongs_to :category
  scope :active, -> { where(is_active: true) }
  scope :by_category, -> (category_id) { where(category_id: category_id) }
  scope :by_price, -> (min_price, max_price) { where(price: min_price..max_price) }
  scope :by_name, -> (name) { where("name ILIKE ?", "%#{name}%") }

  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_many :cart_items, dependent: :destroy
  has_many :carts, through: :cart_items

  has_many_attached :images

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true, length: { minimum: 5, maximum: 255 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
end