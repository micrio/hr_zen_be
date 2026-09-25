# frozen_string_literal: true

class CreatePerformanceReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :performance_reviews do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :reviewer, foreign_key: { to_table: :users }
      t.date :period_start
      t.date :period_end
      t.date :review_date
      t.decimal :rating, precision: 3, scale: 2
      t.string :status, default: "draft", null: false
      t.text :summary
      t.text :strengths
      t.text :improvements
      t.timestamps
    end

    add_index :performance_reviews, %i[organization_id user_id review_date]
  end
end
