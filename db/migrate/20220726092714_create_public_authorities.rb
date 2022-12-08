class CreatePublicAuthorities < ActiveRecord::Migration[6.1]
  def change
    create_table :public_authorities, id: :uuid do |t|
      t.string :pa_name
      t.string :status

      t.timestamps
    end
  end
end
