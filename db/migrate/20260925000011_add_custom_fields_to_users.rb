# frozen_string_literal: true

class AddCustomFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :custom_fields, :jsonb, default: {}, null: false
  end
end
