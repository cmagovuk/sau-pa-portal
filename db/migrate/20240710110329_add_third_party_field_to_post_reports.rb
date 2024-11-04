class AddThirdPartyFieldToPostReports < ActiveRecord::Migration[6.1]
  def change
    add_column :post_reports, :third_party_reps_text, :text
  end
end
