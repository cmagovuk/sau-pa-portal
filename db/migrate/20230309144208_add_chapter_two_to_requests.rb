class AddChapterTwoToRequests < ActiveRecord::Migration[6.1]
  def change
    change_table :requests, bulk: true do |t|
      t.string :is_c2_relevant
      t.text :c2_description
    end
  end
end
