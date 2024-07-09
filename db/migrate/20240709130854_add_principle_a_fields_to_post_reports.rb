class AddPrincipleAFieldsToPostReports < ActiveRecord::Migration[6.1]
  def change
    change_table :post_reports, bulk: true do |t|
      t.string :pa_policy_evidence
      t.string :pa_market_fail
      t.string :pa_equity

      t.text :pa_policy_evidence_text
      t.text :pa_market_fail_text
      t.text :pa_equity_text
    end
  end
end
