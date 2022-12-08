class ChangeColumnsToDecimal < ActiveRecord::Migration[6.1]
  def up
    change_table :requests do |t|
      t.change :budget, :decimal, precision: 20, scale: 2
      t.change :full_amt, :decimal, precision: 20, scale: 2
      t.change :max_amt, :decimal, precision: 20, scale: 2
    end
  end

  def down
    change_table :requests do |t|
      t.change :budget, :integer
      t.change :full_amt, :integer
      t.change :max_amt, :integer
    end
  end
end
