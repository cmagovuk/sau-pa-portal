class AddEeRequiredFieldToPostReports < ActiveRecord::Migration[6.1]
  def change
    add_column :post_reports, :ee_required, :string
  end
end
