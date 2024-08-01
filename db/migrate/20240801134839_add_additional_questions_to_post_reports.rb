class AddAdditionalQuestionsToPostReports < ActiveRecord::Migration[6.1]
  def change
    change_table :post_reports, bulk: true do |t|
      t.string :intl_obligations
      t.string :final_report_url
      t.string :principle_adviser
      t.string :assist_director

      t.text :intl_obligation_values
    end
  end
end
