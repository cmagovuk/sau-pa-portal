class AddTaxRangeToRequests < ActiveRecord::Migration[6.1]
  def change
    change_table :requests, bulk: true do |t|
      t.integer :tax_low
      t.integer :tax_high
    end
  end
end
