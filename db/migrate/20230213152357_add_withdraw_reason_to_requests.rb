class AddWithdrawReasonToRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :requests, :withdraw_reason, :text
  end
end
