class AddReferralNameToPostReports < ActiveRecord::Migration[6.1]
  def change
    add_column :post_reports, :referral_name, :text
  end
end
