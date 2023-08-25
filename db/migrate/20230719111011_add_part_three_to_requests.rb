class AddPartThreeToRequests < ActiveRecord::Migration[6.1]
  def change
    change_table :requests, bulk: true do |t|
      t.string :is_p3_relevant
      t.text :p3_description
    end
  end
end
