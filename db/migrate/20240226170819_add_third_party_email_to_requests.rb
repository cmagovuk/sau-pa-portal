class AddThirdPartyEmailToRequests < ActiveRecord::Migration[6.1]
  def change
    change_table :requests, bulk: true do |t|
      t.string :third_party_email
    end
  end
end
