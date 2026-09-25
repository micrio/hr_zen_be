# frozen_string_literal: true

class AddPayFrequencyToPayrollSettings < ActiveRecord::Migration[7.2]
  def change
    add_column :payroll_settings, :pay_frequency, :string, default: "monthly", null: false
  end
end
