class CreateRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :requests, id: :uuid do |t|
      t.string :scheme_subsidy
      t.string :referral_type
      t.string :created_by
      t.string :status
      t.string :completed_steps
      t.string :reference_number
      t.date :direction_date
      t.references :public_authority, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
