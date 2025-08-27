class CreateAccountUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :account_users do |t|
      t.belongs_to :account, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.json :roles

      t.timestamps
    end

    add_index :account_users, [:account_id, :user_id], unique: true
  end
end
