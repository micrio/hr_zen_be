# frozen_string_literal: true

class CreateAddresses < ActiveRecord::Migration[7.2]
  def change
    create_table :addresses do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :recordable, polymorphic: true
      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country
      t.boolean :primary, default: false
      t.timestamps
    end
  end
end
