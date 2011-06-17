class CreateCheckpoints < ActiveRecord::Migration
  def self.up
    create_table :checkpoints, :id => false do |t|
      t.integer :checkpoint_id
      t.string :checkpoint_name
      
      t.float :checkpoint_loc_lat, :limit => 53
      t.float :checkpoint_loc_long, :limit => 53

#      t.timestamps
    end
  end

  def self.down
    drop_table :checkpoints
  end
end
