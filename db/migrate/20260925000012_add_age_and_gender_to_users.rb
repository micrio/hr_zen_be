# frozen_string_literal: true

class AddAgeAndGenderToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :age, :integer
    add_column :users, :gender, :string
  end
end
