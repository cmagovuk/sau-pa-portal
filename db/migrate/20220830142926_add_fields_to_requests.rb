class AddFieldsToRequests < ActiveRecord::Migration[6.1]
  def change
    change_table :requests, bulk: true do |t|
      t.string :sectors
      t.text :description
      t.string :is_nc
      t.text :nc_description
      t.text :legal
      t.text :policy
      t.string :purposes
      t.string :other_purpose
    end
  end
end
