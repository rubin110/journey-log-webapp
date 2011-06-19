class AddIndices < ActiveRecord::Migration
  def self.up
    add_index :checkins, :checkin_id, :name => :checkin_id
    add_index :checkins, :checkpoint_id
    add_index :checkins, [:runner_id, :checkpoint_id], :unique =>true, :name => :runner_id
    add_index :checkins, [:checkpoint_id, :checkin_time, :is_valid]
    add_index :checkins, [:checkin_time, :checkpoint_id, :is_valid]
    add_index :checkins, :lat
    add_index :checkins, :lng
      
    add_index :checkpoints, :checkpoint_id, :name => :checkpoint_id
    add_index :checkpoints, :checkpoint_position
    add_index :checkpoints, :checkpoint_loc_lat
    add_index :checkpoints, :checkpoint_loc_long
    add_index :checkpoints, [:is_mobile, :is_bonus]

    add_index :runners, :runner_id, :name => :runner_id
    add_index :runners, :is_tagged

    add_index :tags, :tag_id, :name => :tag_id
    add_index :tags, [:runner_id, :tagger_id], :unique => true, :name => :runner_id
    add_index :tags, [:tagger_id, :runner_id]
    add_index :tags, :loc_lat
    add_index :tags, :loc_long
  end

  def self.down
    remove_index :checkins, :checkpoint_id
    remove_index :checkins, [:runner_id, :checkpoint_id]
    remove_index :checkins, [:checkpoint_id, :checkin_time, :is_valid]
    remove_index :checkins, [:checkin_time, :checkpoint_id, :is_valid]
    remove_index :checkins, :lat
    remove_index :checkins, :lng
      
    remove_index :checkpoints, :checkpoint_id
    remove_index :checkpoints, :checkpoint_position
    remove_index :checkpoints, :checkpoint_loc_lat
    remove_index :checkpoints, :checkpoint_loc_long
    remove_index :checkpoints, [:is_mobile, :is_bonus]

    remove_index :runners, :runner_id
    remove_index :runners, :is_tagged

    remove_index :tags, :tag_id
    remove_index :tags, [:runner_id, :tagger_id]
    remove_index :tags, [:tagger_id, :runner_id]
    remove_index :tags, :loc_lat
    remove_index :tags, :loc_long
  end
end
