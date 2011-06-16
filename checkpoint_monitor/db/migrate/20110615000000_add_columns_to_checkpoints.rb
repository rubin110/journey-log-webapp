class AddColumnsToCheckpoints < ActiveRecord::Migration
  def self.up
    add_column :checkpoints, :is_mobile, :boolean, :default => false
    add_column :checkpoints, :is_bonus, :boolean, :default => false
    add_column :checkpoints, :checkpoint_position, :integer
    add_column :checkins, :is_valid, :boolean, :default => true
    
  end

  def self.down
    remove_column :checkpoints, :is_mobile
    remove_column :checkpoints, :is_bonus
    remove_column :checkpoints, :checkpoint_position
    remove_column :checkins, :is_valid
  end
end
