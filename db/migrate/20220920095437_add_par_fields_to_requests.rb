class AddParFieldsToRequests < ActiveRecord::Migration[6.1]
  def change
    change_table :requests, bulk: true do |t|
      t.string :par_on_td
      t.string :par_td_ref_no
      t.string :par_assessed
      t.text :par_reason
      t.date :par_td_date
    end
  end
end
