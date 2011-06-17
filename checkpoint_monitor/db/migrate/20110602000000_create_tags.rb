class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags, :id => false do |t|
      t.integer :tag_id
      t.string :runner_id
      t.string :tagger_id
      t.timestamp :tag_time
      t.float :loc_lat, :limit => 53
      t.float :loc_long, :limit => 53
      t.string :loc_addr
      t.string :device_id
      t.string :user_agent
      t.string :ip_address
    end
  end

  def self.down
    drop_table :tags
  end
end
