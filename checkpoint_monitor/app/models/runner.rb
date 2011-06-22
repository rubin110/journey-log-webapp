class Runner < ActiveRecord::Base
  #has_many :chasers, :class_name => :Runner, :through => :tags, :foreign_key => :runner_id, :primary_key => :tagger_id
  has_many :checkins, :foreign_key => :runner_id, :primary_key => :runner_id
  has_many :tags, :foreign_key => :tagger_id, :primary_key => :runner_id
  has_many :tagged, :class_name => "Tag", :foreign_key => :runner_id, :primary_key => :runner_id

  PHOTO_PATH = '/journey-log/photos/'
  def save_photo(photo_param)
    photo_file = File.join(PHOTO_PATH,"#{runner_id}.jpg")
    File.open(photo_file, "wb") { |f| f.write(photo_param.read) }
  end

  def icon
    is_mugshot ? "/photos/#{runner_id}.jpg" : "/photos/smallrunner.png"
  end

  def img_link
    "<img src='#{icon}' #{is_tagged ? "class='chaser'" : ""} />"
  end    

  def map_html        
    return <<HTML
    <style type="text/css">
  html { height: 100% }
  body { height: 100%; margin: 0px; padding: 0px }
  #map_canvas { height: 100% }
</style>
<div id="map_canvas" style="width:100%; height:100%"></div>
<p>Icons used come from <a href="http://mapicons.nicolasmollet.com/">Nicolas Mollet</a>.</p>
<script type="text/javascript"
src="http://maps.google.com/maps/api/js?sensor=false">
</script>
<script type="text/javascript">
  function initialize() {
    var myOptions = {
      zoom: 13,
      minZoom: 13,
      center: new google.maps.LatLng(37.76878,-122.4151),
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };  
    var map = new google.maps.Map(document.getElementById("map_canvas"),
        myOptions);
    #{checkins.map do |checkin|
      lat = checkin.lat || checkin.checkpoint.checkpoint_loc_lat
      lng = checkin.lng || checkin.checkpoint.checkpoint_loc_long
      lat.nil? ? "" : "new google.maps.Marker({
      position: new google.maps.LatLng(#{lat},#{lng}),
      icon: \"/cpm/icons/jogging.png\",
      title:\"#{checkin.checkpoint.checkpoint_name} (#{checkin.checkin_time.strftime("%H:%M")})\"
      }).setMap(map);"                                  
      end.join("\n")}
    #{tagged.map do |tagged|
      lat = tagged.loc_lat
      lng = tagged.loc_long
      lat.nil? ? "" : "new google.maps.Marker({
      position: new google.maps.LatLng(#{lat},#{lng}),
      icon: \"/cpm/icons/phantom.png\",
      title:\"Tagged by #{tagged.chaser.name}! (#{tagged.tag_time.strftime("%H:%M")})\"
      }).setMap(map);"                                  
      end.join("\n")}
    #{tags.map do |tag|
      lat = tag.loc_lat
      lng = tag.loc_long
      lat.nil? ? "" : "new google.maps.Marker({
      position: new google.maps.LatLng(#{lat},#{lng}),
      icon: \"/cpm/icons/judo.png\",
      title:\"You tagged #{tag.runner.name}!  (#{tag.tag_time.strftime("%H:%M")})\"
      }).setMap(map);"                                  
      end.join("\n")}
  }
  initialize();
</script>

HTML
  end


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
