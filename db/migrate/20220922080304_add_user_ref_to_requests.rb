class AddUserRefToRequests < ActiveRecord::Migration[6.1]
  def change
    add_reference :requests, :user, null: true, foreign_key: true, type: :uuid
  end
end
