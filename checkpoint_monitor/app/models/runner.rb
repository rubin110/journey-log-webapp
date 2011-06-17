class Runner < ActiveRecord::Base
  #has_many :chasers, :class_name => :Runner, :through => :tags, :foreign_key => :runner_id, :primary_key => :tagger_id
  has_many :checkins, :foreign_key => :runner_id, :primary_key => :runner_id
  has_many :tags, :foreign_key => :tagger_id, :primary_key => :runner_id
  has_many :tagged, :class_name => "Tag", :foreign_key => :runner_id, :primary_key => :runner_id

  def name
    player_name || runner_id
  end
  
  def caught_by
    t = Tag.find(:first, :conditions => {:runner_id => runner_id})
    if t.present?
      t.chaser
    else
      nil
    end
  end
  
  def current_time
    latest_positioned_checkin = checkins.find_all{|checkin| checkin.checkpoint.present? && checkin.checkpoint.checkpoint_position.present?}.sort {|a, b| a.checkin_time <=> b.checkin_time}.last
    if (latest_positioned_checkin.present?)
      latest_positioned_checkin.checkin_time
    else
      Checkin.find(:first).checkin_time - 86400
    end
  end
  
  def current_position
    latest_positioned_checkin = checkins.find_all{|checkin| checkin.checkpoint.present? && checkin.checkpoint.checkpoint_position.present?}.sort {|a, b| a.checkin_time <=> b.checkin_time}.last
    if (latest_positioned_checkin.present?)
      latest_positioned_checkin.checkpoint.checkpoint_position
    else
      -1
    end
  end

  def current_checkin
    checkins.sort {|a, b| a.checkin_time <=> b.checkin_time}.last
  end
end
