# frozen_string_literal: true

class CreateRoles < ActiveRecord::Migration[7.2]
  def change
    create_table :roles do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end

    add_index :roles, %i[organization_id name], unique: true
  end
end
