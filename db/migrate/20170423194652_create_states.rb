class CreateStates < ActiveRecord::Migration[5.0]
  def change
    create_table :states do |t|
      t.string :device
      t.string :os
      t.integer :memory, limit: 5
      t.integer :storage, limit: 9

      t.timestamps
    end
  end
end
