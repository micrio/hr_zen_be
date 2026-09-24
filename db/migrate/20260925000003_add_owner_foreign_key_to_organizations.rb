# frozen_string_literal: true

class AddOwnerForeignKeyToOrganizations < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :organizations, :users, column: :owner_id
  end
end
