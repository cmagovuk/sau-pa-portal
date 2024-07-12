class AddWithdrawnReasonToPostReports < ActiveRecord::Migration[6.1]
  def change
    add_column :post_reports, :withdrawn_reason, :text
  end
end
