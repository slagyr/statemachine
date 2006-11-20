class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.column :vending_machine_id, :integer
      t.column :name, :string
      t.column :price, :integer
      t.column :inventory, :integer
    end
  end

  def self.down
    drop_table :products
  end
end
