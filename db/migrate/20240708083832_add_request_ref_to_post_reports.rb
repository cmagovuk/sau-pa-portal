class AddRequestRefToPostReports < ActiveRecord::Migration[6.1]
  def change
    add_reference :post_reports, :request, null: true, foreign_key: true, type: :uuid
  end
end
