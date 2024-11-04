class CreateReportPaNames < ActiveRecord::Migration[6.1]
  def change
    create_table :report_pa_names, id: :uuid do |t|
      t.string :pa_name
      t.string :disabled

      t.timestamps
    end
  end
end
