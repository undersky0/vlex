class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :name
      t.bigint :owner_id
      t.index :owner_id
      t.timestamps
    end
  end
end
