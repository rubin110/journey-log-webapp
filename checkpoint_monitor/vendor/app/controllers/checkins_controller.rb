class CheckinsController < ApplicationController
  skip_before_filter :verify_authenticity_token 

  def checkin
    # if the request does not have runner id and checkpoint id set, then provide a form to enter them
    @checkin = Checkin.new

    if request.post?
      @checkin.runner_id = params[:rid][0,5]
# logger.info "#{params[:rid]} became #{@checkin.runner_id}"
# logger.info "photo is #{params[:runner_photo_file].inspect}"
      @checkin.checkpoint_id = params[:cid]
      if (params[:runner_photo_file])
        Runner.find(:first, :conditions => {:runner_id => @checkin.runner_id}).save_photo(params[:runner_photo_file])
      end
      
      #@checkin.checkin_time = params[:timestamp] ? Time.new(params[:timestamp]) : Time.new
      @checkin.checkin_time = Time.new
      existing_checkin = Checkin.find(:first, :conditions => {:runner_id => @checkin.runner_id, :checkpoint_id => @checkin.checkpoint_id})
      if existing_checkin || @checkin.save
        flash[:notice] = "Checkin successful"
	redirect_to "/cpm/checkins/completed", :runner_id => params[:rid], :checkpoint_id => params[:cid]
      else
        flash[:notice] = "Checkin unsuccessful"
        format.html
      end
    else
       respond_to do |format|
        format.html
        format.xml  { render :xml => @checkin }
      end    
    end
  end
  
  def completed
    @completed_string = "Congratulations, #{params[:runner_id]} has been checked in to #{params[:checkpoint_id]}"
  end
end
