class AddCompletedStepsToPostReports < ActiveRecord::Migration[6.1]
  def change
    add_column :post_reports, :completed_steps, :string
  end
end
