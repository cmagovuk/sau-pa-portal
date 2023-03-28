class AddUmbrellaRefToPublicAuthorities < ActiveRecord::Migration[6.1]
  def change
    add_reference :public_authorities, :umbrella_authority, foreign_key: { to_table: :public_authorities }, type: :uuid
  end
end
