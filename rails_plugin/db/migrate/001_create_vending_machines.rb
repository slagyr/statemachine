class CreateVendingMachines < ActiveRecord::Migration
  def self.up
    create_table :vending_machines do |t|
      t.column :location, :string
      t.column :cash, :integer
    end
  end

  def self.down
    drop_table :vending_machines
  end
end
