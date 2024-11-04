class AddAdditionalFieldsToPostReports < ActiveRecord::Migration[6.1]
  def change
    change_table :post_reports, bulk: true do |t|
      t.string :confi_issues

      t.text :confi_issues_text
      t.text :reject_reason
    end
  end
end
