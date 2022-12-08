class AddSchemeInfoFieldsToRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :requests, :subsidy_form, :string
    add_column :requests, :other_form, :string
    add_column :requests, :budget, :integer
    add_column :requests, :full_amt, :integer
    add_column :requests, :tax_amt, :string
    add_column :requests, :scheme_name, :string
    add_column :requests, :max_amt, :integer
  end
end
