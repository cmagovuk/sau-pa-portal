class AddOrgFieldsToPublicAuthorities < ActiveRecord::Migration[6.1]
  def change
    change_table :public_authorities, bulk: true do |t|
      t.string :org_level_1
      t.string :org_level_2
    end
  end
end
