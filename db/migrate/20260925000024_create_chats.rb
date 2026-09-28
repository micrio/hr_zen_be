# frozen_string_literal: true

class CreateChats < ActiveRecord::Migration[7.2]
  def change
    create_table :chats do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title, default: "New chat", null: false
      t.timestamps
    end
    add_index :chats, %i[organization_id user_id updated_at]

    create_table :chat_messages do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :chat, null: false, foreign_key: true
      t.string :role, null: false
      t.text :content
      t.jsonb :metadata, default: {}, null: false
      t.timestamps
    end
    add_index :chat_messages, %i[chat_id created_at]
  end
end
