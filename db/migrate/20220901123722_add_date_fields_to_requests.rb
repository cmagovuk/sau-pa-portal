class AddDateFieldsToRequests < ActiveRecord::Migration[6.1]
  def change
    change_table :requests, bulk: true do |t|
      t.date :start_date
      t.date :end_date
      t.date :confirm_date
      t.text :info_location
    end
  end
end
