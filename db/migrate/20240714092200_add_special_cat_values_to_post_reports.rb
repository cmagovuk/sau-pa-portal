class AddSpecialCatValuesToPostReports < ActiveRecord::Migration[6.1]
  def change
    add_column :post_reports, :special_cat_values, :text
  end
end
