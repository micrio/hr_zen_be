# frozen_string_literal: true

class CreateOrganizations < ActiveRecord::Migration[7.2]
  def change
    create_table :organizations do |t|
      t.bigint :owner_id
      t.string :name
      t.string :uuid
      t.string :email
      t.string :phone
      t.string :subdomain
      t.datetime :established_at
      t.boolean :status, default: true
      t.timestamps
    end

    add_index :organizations, :owner_id
    add_index :organizations, :subdomain, unique: true
    add_index :organizations, :uuid, unique: true
  end
end
