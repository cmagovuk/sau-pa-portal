class AddReferralDetalFieldsToPostReports < ActiveRecord::Migration[6.1]
  def change
    change_table :post_reports, bulk: true do |t|
      t.string :special_cats
      t.string :third_party_reps

      t.text :special_cats_text
      t.text :value
    end
  end
end
