class AddAdditionalFieldsToRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :requests, :call_in_type, :string
    add_column :requests, :character_desc, :string
  end
end
