class AddSubmittedByRefToRequests < ActiveRecord::Migration[6.1]
  def change
    add_reference :requests, :submitted_by, null: true, foreign_key: false, type: :uuid
  end
end
