class ChangeRequestColumns < ActiveRecord::Migration[6.1]
  def change
    change_column :requests, :assess_pa, :text
    change_column :requests, :assess_pb, :text
    change_column :requests, :assess_pc, :text
    change_column :requests, :assess_pd, :text
    change_column :requests, :assess_pe, :text
    change_column :requests, :assess_pf, :text
    change_column :requests, :assess_pg, :text
    change_column :requests, :character_desc, :text
  end
end
