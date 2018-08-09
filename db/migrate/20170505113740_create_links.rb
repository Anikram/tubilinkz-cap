class CreateLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :links do |t|
      t.string :name, null: false
      t.string :domain
      t.string :url, null: false
      t.integer :clicks, default: 0, null: false

      t.references :user

      t.timestamps
    end

    add_index :links, [:name, :domain], unique: true
    add_foreign_key :links, :users, on_delete: :nullify, on_update: :cascade
  end
end
