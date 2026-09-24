# frozen_string_literal: true

class AddFieldsToRecordTypes < ActiveRecord::Migration[7.2]
  def up
    add_column :record_types, :fields, :jsonb, default: [], null: false

    execute <<~SQL
      UPDATE record_types
      SET fields = COALESCE(
        (
          SELECT jsonb_agg(
            jsonb_build_object(
              'key', kv.key,
              'label', initcap(replace(kv.key, '_', ' ')),
              'type', 'text',
              'level', (kv.value)::int,
              'required', false
            )
          )
          FROM jsonb_each_text(field_levels) AS kv
        ),
        '[]'::jsonb
      )
    SQL

    remove_column :record_types, :field_levels
  end

  def down
    add_column :record_types, :field_levels, :jsonb, default: {}, null: false
    remove_column :record_types, :fields
  end
end
