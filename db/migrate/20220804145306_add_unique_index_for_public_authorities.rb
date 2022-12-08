class AddUniqueIndexForPublicAuthorities < ActiveRecord::Migration[6.1]
  def change
    add_index :public_authorities, :pa_name, unique: true
  end
end
