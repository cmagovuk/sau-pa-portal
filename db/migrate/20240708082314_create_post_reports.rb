class CreatePostReports < ActiveRecord::Migration[6.1]
  def change
    create_table :post_reports, id: :uuid do |t|
      t.string :status

      t.timestamps
    end
  end
end
