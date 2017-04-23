class CreateBugs < ActiveRecord::Migration[5.0]
  def change
    create_table :bugs do |t|
      t.references :app, foreign_key: true
      t.string :number, limit: 30
      t.string :status
      t.string :priority
      t.text :comment, limit: 256
      t.references :state, foreign_key: true

      t.timestamps
    end
    add_index :bugs, :number, unique: true
  end
end
