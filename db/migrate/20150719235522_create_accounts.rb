class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :rname
      t.integer :link_karma

      t.timestamps null: false
    end
  end
end
