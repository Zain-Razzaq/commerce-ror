class User < ApplicationRecord
  has_secure_password

  scope :admin, -> { where(is_admin: true) }
  
  has_many :orders, dependent: :destroy
  has_many :carts, dependent: :destroy
  has_many :cart_items, through: :carts, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }
end