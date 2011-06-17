class CreateRunners < ActiveRecord::Migration
  def self.up
    create_table :runners, :id => false do |t|
      t.string :runner_id
      t.string :player_email
      t.string :player_name
      t.boolean :is_mugshot
      t.timestamp :time_of_mugshot
      t.boolean :is_registered
      t.timestamp :time_of_registration
      t.boolean :is_tagged
      
#      t.string :device_id
#      t.string :browser_id
#      t.timestamps
    end
  end

  def self.down
    drop_table :runners
  end
end
