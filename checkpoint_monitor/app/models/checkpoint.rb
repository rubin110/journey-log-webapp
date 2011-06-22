class Checkpoint < ActiveRecord::Base
  acts_as_mappable  :lat_column_name => :checkpoint_loc_lat, :lng_column_name => :checkpoint_loc_long

  has_many :checkins, :foreign_key => :checkpoint_id, :primary_key => :checkpoint_id

  def num_checked_in
    checkins.size
  end

  def recent_checkins
    checkins.sort_by {|c| c.checkin_time}.reverse[0..19]
  end

  def first_checkins
    checkins.sort_by {|c| c.checkin_time}[0..19]
  end
end
