class RunnersController < ApplicationController
  def show
    @runner = Runner.find(:first, :conditions => {:runner_id => params[:runner_id]})
      
    @num_caught = @runner.tags.size
    @is_chaser = @runner.caught_by.present? || @runner.is_tagged || @num_caught > 0
    
    @num_runners = 963
    
    @num_with_more_catches = nil
    @num_chasers = nil
    if (@is_chaser)
      @num_with_more_catches = ActiveRecord::Base.connection.execute("SELECT COUNT(*) FROM summarized_tags where num_tags > #{@num_caught};").first[0]
      @num_chasers = ActiveRecord::Base.connection.execute("SELECT COUNT(*) from summarized_tags;").first[0]
      @chaser_tree = RunnersController.chaser_descendants(@runner)
    end

    current_checkin = @runner.current_checkin
    
    @your_place_by_checkin = ActiveRecord::Base.connection.execute("select
      runner_checkins.checkin_id,
      checkins_so_far.num_so_far as place_at_this_checkpoint,
      sum(all_checkins_so_far.num_so_far) as place_in_game
    from
      checkins as runner_checkins
    join
      checkins_so_far
    on
      checkins_so_far.checkin_time = runner_checkins.checkin_time
      and checkins_so_far.checkpoint_id = runner_checkins.checkpoint_id
    join
      checkpoints
    on
      checkpoints.checkpoint_id = runner_checkins.checkpoint_id
    join
       checkins_so_far as all_checkins_so_far
    on
      all_checkins_so_far.checkin_time = runner_checkins.checkin_time
      and all_checkins_so_far.checkpoint_position >= checkpoints.checkpoint_position
    where
      runner_checkins.runner_id = '#{@runner.runner_id}'
    group by
      runner_checkins.checkin_id
    order by
      runner_checkins.checkin_time DESC
      ").map do |row|
        [Checkin.find(:first, :conditions => {:checkin_id => row[0]}), row[1].to_i, row[2].to_i]
      end

    @map_html = @runner.map_html
      
    @place = nil
    begin
      @place = ActiveRecord::Base.connection.execute("select place from summarized_runners where runner_id = '#{@runner.runner_id}'").first[0]
    rescue Exception => e
    end
  end
  
  def index
    #@ordered_runners = Runner.find(:all).sort {|a, b| (b.current_checkin.checkpoint_id <=> a.current_checkin.checkpoint_id) || (a.current_checkin.checkin_time.to_i <=> b.current_checkin.checkin_time.to_i)}[0..29]
    #@ordered_runners = Runner.find(:all).sort {|a, b| (b.current_position <=> a.current_position) || (a.current_time.to_i <=> b.current_time.to_i)}[0..29]
    #@ordered_runners = Runner.find(:all).sort {|a, b| (a.current_checkin.checkin_time.to_i <=> b.current_checkin.checkin_time.to_i)}[0..29]
    # @ordered_runners = Runner.find(:all).sort_by {|runner| [-runner.current_position, runner.current_time.to_i]}[0..29]
    #@ordered_chasers = Runner.find(:all).sort_by {|runner| -runner.tags.size}[0..10].find_all{|runner| runner.tags.size > 0}
    @ordered_runners = ActiveRecord::Base.connection.execute("select runner_id from summarized_runners order by place").map {|row| Runner.find(:first, :conditions => {:runner_id => row[0]})}
    @ordered_chasers = ActiveRecord::Base.connection.execute("select tagger_id from summarized_tags order by num_tags desc").map {|row| Runner.find(:first, :conditions => {:runner_id => row[0]})}
#    logger.info("runners: #{@ordered_runners.inspect}, chasers: #{@ordered_chasers.inspect}")
  end

  def chaser_tree
    @chaser_tree = RunnersController.chaser_descendants(nil)
  end
    
  def self.chaser_map(head_chaser)
    chaser_data = Hash.new
    chaser_data["id"] = head_chaser.runner_id
    chaser_data["name"] = head_chaser.name
    chaser_data["children"] = head_chaser.tags.map {|child| chaser_map(child.runner)}
      
    return(chaser_data)
  end
  
  def self.chaser_descendants(head_chaser)
    if (head_chaser.nil?)
      chaser_data = Hash.new
      chaser_data["id"] = "CHASR"
      chaser_data["name"] = "The Great Chaser Spirit"
      all_tags = Tag.find(:all)
      all_taggers = all_tags.map{|tag| tag.chaser.runner_id}.uniq
      all_tagged = all_tags.map{|tag| tag.runner.runner_id}.uniq
      all_unknown_origin_chasers = (all_taggers - all_tagged).map {|runner_id| Runner.find(:first, :conditions => {:runner_id => runner_id})}
      
      chaser_data["children"] = all_unknown_origin_chasers.map {|chaser| chaser_map(chaser)}
    else 
      chaser_data = RunnersController.chaser_map(head_chaser)
    end
    
    return <<JS
    <!-- <link type="text/css" href="/20110618-sf/cpm/stylesheets/jit/base.css" rel="stylesheet" /> -->
    <link type="text/css" href="/20110618-sf/cpm/stylesheets/jit/Hypertree.css" rel="stylesheet" />
    
    <!--[if IE]><script language="javascript" type="text/javascript" src="/20110618-sf/cpm/javascripts/vendor/jit/excanvas.js"></script><![endif]-->
    
    <!-- JIT Library File -->
    <script language="javascript" type="text/javascript" src="/20110618-sf/cpm/javascripts/vendor/jit/jit-yc.js"></script>
    
    <div id="container">
    
    <div id="left-container">

    <div class="text">
                Clicking on a chaser node should move the tree and center that node.<br /><br />
            </div>
    
            <div id="id-list"></div>
    </div>
    
    <div id="center-container">
        <div id="infovis"></div>    
    
    </div>
    
    <div id="right-container">
    
    <div id="inner-details"></div>
    
    </div>
    
    <div id="log"></div>
    </div>
    
    <script>
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
    var json = #{chaser_data.to_json};
  var infovis = document.getElementById('infovis');
  var w = infovis.offsetWidth - 50, h = infovis.offsetHeight - 50;
  
  //init Hypertree
  var ht = new $jit.Hypertree({
    //id of the visualization container
    injectInto: 'infovis',
    //canvas width and height
    width: w,
    height: h,
    //Change node and edge styles such as
    //color, width and dimensions.
    Node: {
        dim: 9,
        color: "#f00"
    },
    Edge: {
        lineWidth: 2,
        color: "#088"
    },
    onBeforeCompute: function(node){
    },
    //Attach event handlers and add text to the
    //labels. This method is only triggered on label
    //creation
    onCreateLabel: function(domElement, node){
        domElement.innerHTML = node.name;
        $jit.util.addEvent(domElement, 'click', function () {
            ht.onClick(node.id, {
                onComplete: function() {
                    ht.controller.onComplete();
                }
            });
        });
    },
    //Change node styles when labels are placed
    //or moved.
    onPlaceLabel: function(domElement, node){
        var style = domElement.style;
        style.display = '';
        style.cursor = 'pointer';
        if (node._depth <= 1) {
            style.fontSize = "0.8em";
            style.color = "#ddd";

        } else if(node._depth == 2){
            style.fontSize = "0.7em";
            style.color = "#555";

        } else {
            style.display = 'none';
        }

        var left = parseInt(style.left);
        var w = domElement.offsetWidth;
        style.left = (left - w / 2) + 'px';
    },
    
    onComplete: function(){
    }
  });
  //load JSON data.
  ht.loadJSON(json);
  //compute positions and plot.
  ht.refresh();
  //end
  ht.controller.onComplete();
}
    
init();    
    </script>
JS
  end
end
