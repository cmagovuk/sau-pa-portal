class AddRequestRefToInformationRequests < ActiveRecord::Migration[6.1]
  def change
    add_reference :information_requests, :request, null: false, foreign_key: true, type: :uuid
  end
end
