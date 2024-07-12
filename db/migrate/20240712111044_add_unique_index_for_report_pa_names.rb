class AddUniqueIndexForReportPaNames < ActiveRecord::Migration[6.1]
  def change
    add_index :report_pa_names, :pa_name, unique: true
  end
end
