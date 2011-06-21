class CheckpointsController < ApplicationController
  def index
    @checkpoints = Checkpoint.find(:all)
  end

  def show
    @checkpoint = Checkpoint.find(:first, :conditions => {:checkpoint_id => params[:checkpoint_id]})
    @activity_string = ""

    begin
      sc = SummarizedCheckpointInfo.new(@checkpoint)
      start_time = sc.first_checkin_time
      end_time = sc.last_checkin_time
      if (start_time.present?)
        minute_interval = 1

        num_intervals = ((end_time - start_time)/(minute_interval * 60.0)).ceil    
        end_times = (1..num_intervals).map {|interval_index| start_time + minute_interval*interval_index*60}

        @activity_string = ActivityController.line_plot(end_times, {"activity" => sc.checkin_hist(start_time,end_time,minute_interval)})
      end
    rescue Exception => e
      logger.info(e.to_s)
    end
     
  end

end
