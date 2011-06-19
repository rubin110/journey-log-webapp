class AutoincrementCheckinAndTagIds < ActiveRecord::Migration
  def self.up
    change_column :checkins, :checkin_id, :primary_key
    change_column :tags, :tag_id, :primary_key
  end

  def self.down
    change_column :checkins, :checkin_id, :integer
    change_column :tags, :tag_id, :integer
  end
end
