class AddEePrincipleFieldsToPostReports < ActiveRecord::Migration[6.1]
  def change
    change_table :post_reports, bulk: true do |t|
      t.string :ee_relevant
      t.string :ee_principles
      t.string :ee_issues
      t.string :other_issues

      t.text :ee_principles_text
      t.text :ee_issues_text
      t.text :other_issues_text
    end
  end
end
