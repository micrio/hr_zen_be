# frozen_string_literal: true

class CreateFaceEmbeddingsAndAttendanceEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :face_embeddings do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.jsonb :vector, null: false, default: []
      t.integer :dimension, null: false, default: 0
      t.string :source, default: "camera"
      t.timestamps
    end
    add_index :face_embeddings, %i[organization_id user_id]

    create_table :attendance_events do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :kind, null: false
      t.datetime :occurred_at, null: false
      t.float :distance
      t.string :source, default: "face"
      t.timestamps
    end
    add_index :attendance_events, %i[organization_id user_id occurred_at]
  end
end
