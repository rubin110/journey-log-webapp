class Tag < ActiveRecord::Base
  set_primary_key :tag_id
  acts_as_mappable  :lat_column_name => :loc_lat, :lng_column_name => :loc_long

  belongs_to :runner, :foreign_key => :runner_id, :primary_key => :runner_id
  belongs_to :chaser, :class_name => "Runner", :foreign_key => :tagger_id, :primary_key => :runner_id  
end
