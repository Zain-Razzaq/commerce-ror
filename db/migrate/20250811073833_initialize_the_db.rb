class InitializeTheDb < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.boolean :is_admin, default: false
      t.timestamps
    end

    create_table :categories do |t|
      t.string :name
      t.timestamps
    end

    create_table :products do |t|
      t.string :name
      t.string :description
      t.decimal :price
      t.integer :stock
      t.boolean :is_active, default: true
      t.references :category, null: false, foreign_key: true
      t.timestamps
    end

    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status, default: 0
      t.string :shipping_address
      t.timestamps
    end

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity
      t.decimal :price
      t.timestamps
    end

    create_table :carts do |t|
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity
      t.timestamps
    end
  end
end
