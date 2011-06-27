class Runner < ActiveRecord::Base
  #has_many :chasers, :class_name => :Runner, :through => :tags, :foreign_key => :runner_id, :primary_key => :tagger_id
  has_many :checkins, :foreign_key => :runner_id, :primary_key => :runner_id
  has_many :tags, :foreign_key => :tagger_id, :primary_key => :runner_id
  has_many :tagged, :class_name => "Tag", :foreign_key => :runner_id, :primary_key => :runner_id

  PHOTO_PATH = '/20110618-sf/photos/'
  def save_photo(photo_param)
    photo_file = File.join(PHOTO_PATH,"#{runner_id}.jpg")
    File.open(photo_file, "wb") { |f| f.write(photo_param.read) }
  end

  def icon
    is_mugshot ? "/20110618-sf/photos/#{runner_id}.jpg" : "/20110618-sf/photos/smallrunner.png"
  end

  def img_link
    "<img src='#{icon}' #{is_tagged ? "class='chaser'" : ""} />"
  end    

  def map_html
    lat_array = []
    lng_array = []
    color_array = []
    marker_id_array = []
    marker_timer_array = []
    min_time = nil
    checkin_markers = checkins.sort_by{|c| c.checkin_time}.map do |checkin|
      lat = checkin.lat || checkin.checkpoint.checkpoint_loc_lat
      lng = checkin.lng || checkin.checkpoint.checkpoint_loc_long
      if !lat.nil?
        lat_array << lat
        lng_array << lng
        color_array << "0000FF"
        marker_id_array << "checkin_marker_#{checkin.checkpoint.checkpoint_id}"
        marker_timer_array << checkin.checkin_time
      end
      lat.nil? ? nil : "var checkin_marker_#{checkin.checkpoint.checkpoint_id} = new google.maps.Marker({
      position: new google.maps.LatLng(#{lat},#{lng}),
      icon: \"/cpm/icons/jogging.png\",
      title:\"#{checkin.checkpoint.checkpoint_name} (#{checkin.checkin_time.strftime("%H:%M")})\",      
      });
      checkin_marker_#{checkin.checkpoint.checkpoint_id}.setMap(map);
      google.maps.event.addListener(checkin_marker_#{checkin.checkpoint.checkpoint_id}, 'click', function() {
        infowindow.setContent(\"#{checkin.checkpoint.checkpoint_name} (#{checkin.checkin_time.strftime("%H:%M")})\");
        infowindow.open(map,checkin_marker_#{checkin.checkpoint.checkpoint_id});
      });"
    end.compact
    tagged_markers = tagged.map do |tagged|
      lat = tagged.loc_lat
      lng = tagged.loc_long
      if !lat.nil?
        lat_array << lat
        lng_array << lng
        color_array << "FF0000"
        marker_id_array << "tagged_#{tagged.tag_id}"
        marker_timer_array << tagged.tag_time
      end
      lat.nil? ? nil : "var tagged_#{tagged.tag_id} = new google.maps.Marker({
      position: new google.maps.LatLng(#{lat},#{lng}),
      icon: \"/cpm/icons/phantom.png\",
      title:\"Tagged by #{tagged.chaser.name}! (#{tagged.tag_time.strftime("%H:%M")})\"
      });
      tagged_#{tagged.tag_id}.setMap(map);
      google.maps.event.addListener(tagged_#{tagged.tag_id}, 'click', function() {
        infowindow.setContent(\"Tagged by #{tagged.chaser.name}! (#{tagged.tag_time.strftime("%H:%M")})\");
        infowindow.open(map,tagged_#{tagged.tag_id});
      });"
    end.compact
    tag_markers = tags.sort_by{|t| t.tag_time}.map do |tag|
      lat = tag.loc_lat
      lng = tag.loc_long
      if !lat.nil?
        lat_array << lat
        lng_array << lng
        color_array << "FF0000"
        marker_id_array << "tag_#{tag.tag_id}"
        marker_timer_array << tag.tag_time
      end
      lat.nil? ? nil : "var tag_#{tag.tag_id} = new google.maps.Marker({
      position: new google.maps.LatLng(#{lat},#{lng}),
      icon: \"/cpm/icons/judo.png\",
      title:\"Tagged #{tag.runner.name}!  (#{tag.tag_time.strftime("%H:%M")})\"
      });
      tag_#{tag.tag_id}.setMap(map);
      google.maps.event.addListener(tag_#{tag.tag_id}, 'click', function() {
        infowindow.setContent(\"Tagged #{tag.runner.name}!  (#{tag.tag_time.strftime("%H:%M")})\");
        infowindow.open(map,tag_#{tag.tag_id});
      });"
    end.compact
    marker_array = (checkin_markers << tagged_markers << tag_markers).flatten
    overlay_array = []
    if (marker_array.size > 1)
      overlay_array = [marker_array[0]]
      Range.new(1, marker_array.size-1).each do |index|
        overlay_array << "new google.maps.Polyline({
          path: [new google.maps.LatLng(#{lat_array[index-1]},#{lng_array[index-1]}), new google.maps.LatLng(#{lat_array[index]},#{lng_array[index]})],
          strokeColor: \"##{color_array[index-1]}\",
          strokeOpacity: 1.0,
          strokeWeight: 2
        }).setMap(map);"
        overlay_array << marker_array[index]
      end
    end
    if (marker_timer_array.size > 0)
      time_range = marker_timer_array.max.to_i - marker_timer_array.min.to_i
      marker_timer_array = marker_timer_array.map {|t| ((t.to_i - marker_timer_array.min.to_i)*5000.0/time_range).round}
    end
    return <<HTML
    <style type="text/css">
  html { height: 100% }
  body { height: 100%; margin: 0px; padding: 0px }
  #map_canvas { height: 100% }
</style>
<input type="button" value="Replay" onClick="play();" />
<div id="map_canvas" style="width:100%; height:100%"></div>
<p>Icons used come from <a href="http://mapicons.nicolasmollet.com/">Nicolas Mollet</a>.</p>
<script type="text/javascript"
src="http://maps.google.com/maps/api/js?sensor=false">
</script>
<script type="text/javascript">
    var myOptions = {
      zoom: 13,
      minZoom: 13,
      center: new google.maps.LatLng(37.76878,-122.4151),
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };  
    var map = new google.maps.Map(document.getElementById("map_canvas"),
        myOptions);
    var infowindow = new google.maps.InfoWindow({content: ""});

    #{overlay_array.join("\n")}
  function play() {
    #{Range.new(0,marker_id_array.size-1).map do |index|
      marker_id = marker_id_array[index]
      "setTimeout(function() {
        #{marker_id}.setAnimation(google.maps.Animation.BOUNCE);
      }, #{marker_timer_array[index]});
      setTimeout(function() {
        #{marker_id}.setAnimation(null);
      }, #{(index == marker_timer_array.size-1) ? marker_timer_array[index] + 1000 : marker_timer_array[index+1]});"
      end.join("\n")}
  }
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
