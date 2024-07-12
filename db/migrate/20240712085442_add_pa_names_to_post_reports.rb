class AddPaNamesToPostReports < ActiveRecord::Migration[6.1]
  def change
    add_column :post_reports, :pa_names, :text
  end
end
