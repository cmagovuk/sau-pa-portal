class AddPrincipleFieldsToPostReports < ActiveRecord::Migration[6.1]
  def change
    change_table :post_reports, bulk: true do |t|
      t.string :pe_policy
      t.string :pe_other_means
      t.string :pc_counterfactual
      t.string :pc_eco_behaviour
      t.string :pd_additionality
      t.string :pd_costs
      t.string :pb_proportion
      t.string :pf_subsidy_char
      t.string :pf_market_char
      t.string :pg_balance_uk
      t.string :pg_balance_intl
      t.string :ee_engaged
      t.string :ee_reasoning

      t.text :pe_policy_text
      t.text :pe_other_means_text
      t.text :pc_counterfactual_text
      t.text :pc_eco_behaviour_text
      t.text :pd_additionality_text
      t.text :pd_costs_text
      t.text :pb_proportion_text
      t.text :pf_subsidy_char_text
      t.text :pf_market_char_text
      t.text :pg_balance_uk_text
      t.text :pg_balance_intl_text
      t.text :ee_engaged_text
      t.text :ee_reasoning_text
    end
  end
end
