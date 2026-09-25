# frozen_string_literal: true

class CreateWorkManagement < ActiveRecord::Migration[7.2]
  def change
    create_table :teams do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.references :lead, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :teams, %i[organization_id name], unique: true

    create_table :team_members do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
    add_index :team_members, %i[team_id user_id], unique: true

    create_table :projects do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :team, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :status, default: "active", null: false
      t.date :start_date
      t.date :end_date
      t.timestamps
    end
    add_index :projects, %i[organization_id name], unique: true

    create_table :tasks do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.references :assignee, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :description
      t.string :status, default: "todo", null: false
      t.string :priority, default: "medium", null: false
      t.date :due_date
      t.timestamps
    end
    add_index :tasks, %i[organization_id project_id status]
  end
end
