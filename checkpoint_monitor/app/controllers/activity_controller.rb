class ActivityController < ApplicationController
  def recent
    @recent_twenty_checkins = Checkin.find(:all, :order => 'checkin_time desc', :limit => 20)
    @recent_twenty_tags = Tag.find(:all, :order => 'tag_time desc', :limit => 20)    
  end
  
  def status
    @all_checkpoints = Checkpoint.find(:all).find_all{|cp| !cp.checkpoint_position.nil?}.sort {|a, b| (a.checkpoint_position <=> b.checkpoint_position) || (a.checkpoint_name <=> b.checkpoint_name)}
    
    @summarized_checkpoints = @all_checkpoints.map {|c| SummarizedCheckpointInfo.new(c)}
      
    @total_players = ActiveRecord::Base.connection.execute("select count(distinct runner_id) from (select runner_id 
from runners where is_mugshot=1 or is_registered=1 union all select runner_id from tags union all select tagger_id 
from tags union all select runner_id from checkins) as all_runners;").first[0]
      
    # TODO: also report on how many players are known to have become chasers, and what the highest number of reported catches is so far
      
    # in the view, show the by-minute-interval plot of activity at each checkpoint
    end_time = @summarized_checkpoints.map {|sc| sc.last_checkin_time}.compact.max
    start_time = [@summarized_checkpoints.map {|sc| sc.first_checkin_time}.compact.min, end_time - 86400].max
    minute_interval=5
    num_intervals = ((end_time - start_time)/(minute_interval * 60.0)).ceil    
    end_times = (1..num_intervals).map {|interval_index| start_time + minute_interval*interval_index*60}
    
    merged_map = @summarized_checkpoints.inject({}) {|total, sm| total.merge(sm.checkpoint.checkpoint_name => sm.checkin_hist(start_time,end_time,minute_interval))}
      
    # use flot to plot the activity over time in merged_map
      
    @line_plot = ActivityController.line_plot(end_times, merged_map)

    # get the highest checkpoint position reached by each player; do a stream graph of the highest checkpoint each person has reached, by time
    @status_plot = ""
    begin
      checkpoint_positions = @summarized_checkpoints.map{|sm| sm.checkpoint.checkpoint_position}.compact.uniq
      current_counts = checkpoint_positions.inject({}) {|new_counts, pos| new_counts = new_counts.merge(pos => 0)}
      current_positions = Hash.new()
      time_map = Hash.new()
      end_time_index = 0
      Checkin.find(:all, :order => 'checkin_time').each do |checkin|
        if (current_positions.has_key?(checkin.runner_id))
          current_counts[current_positions[checkin.runner_id]] = current_counts[current_positions[checkin.runner_id]] - 1
        end
        if (checkin.checkpoint.present? && checkin.checkpoint.checkpoint_position.present?)
          current_positions[checkin.runner_id] = checkin.checkpoint.checkpoint_position
#          logger.info("Checking in at cp #{checkin.checkpoint.checkpoint_position}, currently #{current_counts.inspect}")
          current_counts[checkin.checkpoint.checkpoint_position] = current_counts[checkin.checkpoint.checkpoint_position] + 1
          if ((end_time_index < end_times.size) && (checkin.checkin_time >= end_times[end_time_index]))
            time_map[end_times[end_time_index]] = checkpoint_positions.map {|cpp| current_counts[cpp]}
            end_time_index = end_time_index + 1
          end
        end
      end
#      logger.info("Plotting times #{end_times.inspect} with data #{time_map.inspect}")

      time_map_by_highest_checkpoint = {"label" => checkpoint_positions, "values" => end_times.map {|time| {"label" => time.strftime("%H:%M"), "values" => time_map[time]}}}
      logger.info("Plotting with data #{time_map_by_highest_checkpoint.inspect}")
      @status_plot = ActivityController.stream_plot(time_map_by_highest_checkpoint)
    rescue Exception => e
      logger.info("#{e.to_s}: #{e.backtrace}")
    end
    
  end 
  
  def self.line_plot(x_axis, data_hash)
    x_axis = x_axis.map{|t| t.to_i * 1000}
    series_names = data_hash.keys
    
    basename="activity"
    x_is_timestamp = true
    x_is_character = false
    xlab=""
    ylab="number of runners checking in"
    main="checkpoint activity over time"
    tooltip = nil
    extra_parameters = ""
    
    return <<JS
    <table><tr><td></td><td align="center">#{main}</td></tr>
    <tr><td class="rotate"><!-- <div class="textrotate">#{ylab}</div> --></td><td>
    <div id="#{basename}_placeholder" style="width:900px;height:450px"></div>
    </td></tr>
    <tr><td></td><td align="center">#{xlab}</td></tr>
    <tr><td></td><td>
    <div id="#{basename}_overview" style="margin-left:30px;margin-top:20px;width:600px;height:50px"></div>
    <br />Select an area to zoom.  <input type="submit" name="#{basename}_reset_zoom" id="#{basename}_reset_zoom" value="Reset Zoom" />
    </td></tr>
    </table>
    
    <!--[if lte IE 8]><script language="javascript" type="text/javascript" 
src="/20110618-sf/cpm/javascripts/vendor/flot/excanvas.min.js"></script><![endif]-->
    <script language="javascript" type="text/javascript" 
src="/20110618-sf/cpm/javascripts/vendor/flot/jquery.js"></script>
    <script language="javascript" type="text/javascript" 
src="/20110618-sf/cpm/javascripts/vendor/flot/jquery.flot.js"></script>
    <script language="javascript" type="text/javascript" 
src="/20110618-sf/cpm/javascripts/vendor/flot/jquery.flot.selection.js"></script>

    <script id="#{basename}_source" language="javascript" type="text/javascript">
    $(function () {
      #{x_is_character ? "var #{basename}_data = #{data_hash.values.map{|data_list| data_list.enum_for(:each_with_index).collect{|data_point, i| [i, data_point]}}.to_json};\n var #{basename}_ticks = #{x_axis.enum_for(:each_with_index).collect{|label, i| [i, label]}.to_json};" : "var #{basename}_data = #{data_hash.values.map{|data_list| data_list.enum_for(:each_with_index).collect{|data_point, i| [x_axis[i], data_point]}}.to_json};"}
    
      #{tooltip.nil? ? "var #{basename}_named_data = [#{series_names.each_index.map {|i| "{ data: #{basename}_data[#{i}], label: '#{series_names[i]}'}"}.join(', ')}];" :
                      "var #{basename}_tooltip = [#{series_names.each_index.map {|i| "#{tooltip_list[i].to_json}"}.join(', ')}];
                      var #{basename}_named_data = [#{series_names.each_index.map {|i| "{ data: #{basename}_data[#{i}], tooltip: #{basename}_tooltip[#{i}], label: '#{series_names[i]}'}"}.join(', ')}];" }
    
      var #{basename}_options = {
                 series: {
                     #{!x_is_character ? "lines: { show: true }," : ""}
                     points: { show: true }
                 },
                #{x_is_character ? "xaxis: {ticks: #{basename}_ticks}," : ""}
    
    
                #{x_is_timestamp ? "xaxis: { mode: 'time' }," : ""}
                 grid: { hoverable: true},
                  legend: { position: 'nw' },
                  #{extra_parameters}
                  selection: { mode: "x" }
               };
    
      var #{basename} = $.plot($("##{basename}_placeholder"), #{basename}_named_data, #{basename}_options);
    
      function #{basename}_showTooltip(x, y, contents) {
          $('<div id="#{basename}_tooltip">' + contents + '</div>').css( {
              position: 'absolute',
              display: 'none',
              top: y + 5,
              left: x + 5,
              border: '1px solid #fdd',
              padding: '2px',
              'background-color': '#fee',
              opacity: 0.80
          }).appendTo("body").fadeIn(0);
      }
    
      var #{basename}_previousPoint = null;
      $("##{basename}_placeholder").bind("plothover", function (event, pos, item) {
          $("#x").text(pos.x.toFixed(2));
          $("#y").text(pos.y.toFixed(2));
    
          if (item) {
              if (#{basename}_previousPoint != item.datapoint) {
                  #{basename}_previousPoint = item.datapoint;
    
                  $("##{basename}_tooltip").remove();
                  var x = #{x_is_timestamp ? "item.datapoint[0]" : "item.datapoint[0].toFixed(2)"},
                      y = item.datapoint[1].toFixed(2);
    
                  #{basename}_showTooltip(item.pageX, item.pageY,
                              item.series.label + " at " + #{x_is_timestamp ? "$.plot.formatDate(new Date(x), '%y-%m-%d %h:%M:%S')" : "x"} + " = " + y#{tooltip.nil? ? '' : '+ " (" + item.series.tooltip[item.dataIndex] + ")"'});
              }
          }
          else {
              $("##{basename}_tooltip").remove();
              #{basename}_previousPoint = null;
          }
      });
    
      var #{basename}_overview = $.plot($("##{basename}_overview"), #{basename}_named_data, {
              series: {
                  lines: { show: true, lineWidth: 1 },
                  shadowSize: 0
              },
              xaxis: { ticks: [], #{x_is_timestamp ? "mode: 'time'" : ""} },
              yaxis: { ticks: [], min: 0, autoscaleMargin: 0.1 },
              legend: { show:false },
              selection: { mode: "x" }
          });
    
      $("##{basename}_placeholder").bind("plotselected", function (event, ranges) {
          // do the zooming
          // TODO: auto-zoom the y-axis
          #{basename} = $.plot($("##{basename}_placeholder"), #{basename}_named_data,
                        $.extend(true, {}, #{basename}_options, {
                            xaxis: { min: ranges.xaxis.from, max: ranges.xaxis.to }
                        }));
    
          // don't fire event on the overview to prevent eternal loop
          #{basename}_overview.setSelection(ranges, true);
      });
    
      $("##{basename}_overview").bind("plotselected", function (event, ranges) {
          #{basename}.setSelection(ranges);
      });
    
      $("##{basename}_reset_zoom").click(function() {
        #{basename} = $.plot($("##{basename}_placeholder"), #{basename}_named_data, #{basename}_options);
        #{basename}_overview.clearSelection();
      });
    });
    </script>
JS
  end
  
  def self.stream_plot(stream_data)
#    series_names = data_hash.keys.sort

#    stream_data = Hash.new
#    stream_data["label"] = series_names
#    stream_data["values"] = times.map {|time|
#      index = times.index(time)
#      {'label' => time.strftime("%H:%M"),
#      'values' => data_hash.values.map{|array| array[index]}}
#    }

    return <<JS
  <div id="infovis" class="infovis"> </div>
    <!-- <link type="text/css" href="/20110618-sf/cpm/stylesheets/jit/base.css" rel="stylesheet" /> -->
    <link type="text/css" href="/20110618-sf/cpm/stylesheets/jit/AreaChart.css" rel="stylesheet" />
        <!--[if IE]><script language="javascript" type="text/javascript" src="/20110618-sf/cpm/javascripts/vendor/jit/excanvas.js"></script><![endif]-->
    
    <!-- JIT Library File -->
    <script language="javascript" type="text/javascript" src="/20110618-sf/cpm/javascripts/vendor/jit/jit-yc.js"></script>
  
  <script id="sp_source" language="javascript" type="text/javascript">
var labelType, useGradients, nativeTextSupport, animate;

(function() {
  var ua = navigator.userAgent,
      iStuff = ua.match(/iPhone/i) || ua.match(/iPad/i),
      typeOfCanvas = typeof HTMLCanvasElement,
      nativeCanvasSupport = (typeOfCanvas == 'object' || typeOfCanvas == 'function'),
      textSupport = nativeCanvasSupport
        && (typeof document.createElement('canvas').getContext('2d').fillText == 'function');
  //I'm setting this based on the fact that ExCanvas provides text support for IE
  //and that as of today iPhone/iPad current text support is lame
  labelType = (!nativeCanvasSupport || (textSupport && !iStuff))? 'Native' : 'HTML';
  nativeTextSupport = labelType == 'Native';
  useGradients = nativeCanvasSupport;
  animate = !(iStuff || !nativeCanvasSupport);
})();

var Log = {
  elem: false,
  write: function(text){
    if (!this.elem)
      this.elem = document.getElementById('log');
    this.elem.innerHTML = text;
    this.elem.style.left = (500 - this.elem.offsetWidth / 2) + 'px';
  }
};


function init(){
    //init data
    var json = #{stream_data.to_json};
    var infovis = document.getElementById('infovis');
    //init AreaChart
    var areaChart = new $jit.AreaChart({
      //id of the visualization container
      injectInto: 'infovis',
      //add animations
      animate: true,
      //separation offsets
      Margin: {
        top: 5,
        left: 5,
        right: 5,
        bottom: 5
      },
      labelOffset: 10,
      //whether to display sums
      showAggregates: true,
      //whether to display labels at all
      showLabels: true,
      //could also be 'stacked'
      type: useGradients? 'stacked:gradient' : 'stacked',
      //label styling
      Label: {
        type: labelType, //can be 'Native' or 'HTML'
        size: 13,
        family: 'Arial',
        color: 'white'
      },
      //enable tips
      Tips: {
        enable: true,
        onShow: function(tip, elem) {
          tip.innerHTML = "<b>" + elem.name + "</b>: " + elem.value;
        }
      },
    });
    //load JSON data.
    areaChart.loadJSON(json);
    //end
    var list = $jit.id('id-list'),
        button = $jit.id('update'),
        restoreButton = $jit.id('restore');
    //dynamically add legend to list
    var legend = areaChart.getLegend(),
        listItems = [];
    for(var name in legend) {
      listItems.push("<div class='query-color' style='background-color:" + legend[name] +"'>&nbsp;</div>" + name);
    }
    list.innerHTML = '<li>' + listItems.join('</li><li>') + '</li>';
}
init();
  </script>
JS
  end
end
