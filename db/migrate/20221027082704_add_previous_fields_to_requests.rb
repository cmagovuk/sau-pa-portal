class AddPreviousFieldsToRequests < ActiveRecord::Migration[6.1]
  def change
    change_table :requests, bulk: true do |t|
      t.string :previous_refno
      t.string :previous_status
      t.uuid :previous_id
      t.date :sau_call_in
    end
  end
end
