class AddBeneficiaryToRequests < ActiveRecord::Migration[6.1]
  def change
    change_table :requests, bulk: true do |t|
      t.string :beneficiary
      t.string :ben_id_type
      t.string :ben_id
      t.string :ben_size
      t.string :ben_good_svr
      t.string :location
      t.string :internal_state
      t.text :other_loc
    end
  end
end
