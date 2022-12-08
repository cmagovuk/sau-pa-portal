class CreateAuditLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :audit_logs, id: :uuid do |t|
      t.string :user_name
      t.string :user_email
      t.string :message
      t.string :event_type
      t.references :public_authority, null: true, type: :uuid
      t.references :log, polymorphic: true, type: :uuid
      t.timestamps
    end
  end
end
