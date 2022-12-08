class AddAssessmentFieldsToRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :requests, :assess_pa, :string
    add_column :requests, :assess_pb, :string
    add_column :requests, :assess_pc, :string
    add_column :requests, :assess_pd, :string
    add_column :requests, :assess_pe, :string
    add_column :requests, :assess_pf, :string
    add_column :requests, :assess_pg, :string
  end
end
