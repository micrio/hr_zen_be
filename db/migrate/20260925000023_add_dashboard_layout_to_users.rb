# frozen_string_literal: true

class AddDashboardLayoutToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :dashboard_layout, :jsonb, default: [], null: false
  end
end
