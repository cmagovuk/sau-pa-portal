class AddSchemeFieldsToRequests < ActiveRecord::Migration[6.1]
  def change
    change_table :requests, bulk: true do |t|
      t.string :is_emergency
      t.string :max_amt_s
      t.string :subsidy_forms
      t.text :emergency_desc
    end
  end
end
