class CreateApps < ActiveRecord::Migration[5.0]
  def change
    create_table :apps do |t|
      t.string :token

      t.timestamps
    end
    add_index :apps, :token, unique: true
  end
end
