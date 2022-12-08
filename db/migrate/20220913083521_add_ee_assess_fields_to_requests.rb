class AddEeAssessFieldsToRequests < ActiveRecord::Migration[6.1]
  def change
    change_table :requests, bulk: true do |t|
      t.string :ee_assess_required
      t.text :assess_ee_pa
      t.text :assess_ee_pb
      t.text :assess_ee_pc
      t.text :assess_ee_pd
      t.text :assess_ee_pe
      t.text :assess_ee_pf
      t.text :assess_ee_pg
      t.text :assess_ee_ph
      t.text :assess_ee_pi
    end
  end
end
