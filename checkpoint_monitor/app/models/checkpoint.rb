class Checkpoint < ActiveRecord::Base
  acts_as_mappable  :lat_column_name => :checkpoint_loc_lat, :lng_column_name => :checkpoint_loc_long

  has_many :checkins, :foreign_key => :checkpoint_id, :primary_key => :checkpoint_id
end
