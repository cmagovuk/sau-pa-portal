class AddDatesToRequests < ActiveRecord::Migration[6.1]
  def change
    change_table :requests, bulk: true do |t|
      t.date :report_due_date
      t.datetime :submitted_date
      t.datetime :decision_date
      t.datetime :completed_date
    end
  end
end
