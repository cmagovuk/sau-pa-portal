class AddDisabledToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :disabled, :string
  end
end
