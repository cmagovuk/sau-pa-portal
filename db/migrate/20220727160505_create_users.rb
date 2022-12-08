class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :user_name
      t.string :email
      t.string :oid
      t.string :phone
      t.references :public_authority, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
