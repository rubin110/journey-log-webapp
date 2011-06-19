class CreateCheckins < ActiveRecord::Migration
  def self.up
    create_table :checkins, :id => false do |t|
      t.integer :checkin_id
      t.string :runner_id
      t.integer :checkpoint_id
      t.timestamp :checkin_time
      t.string :device_id
      t.string :user_agent
      t.string :ip_address
      
      t.float :lng, :limit => 53
      t.float :lat, :limit => 53
#      t.timestamp :reported_timestamp
#      t.string :checksum
#      t.timestamps
    end
  end

  def self.down
    drop_table :checkins
  end
end
