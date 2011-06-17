class SummarizedRunnerInfo
  attr_reader :runner, :checkin_list, :first_checkin_time, :last_checkin_time, :current_checkpoint 
  
  def initialize(runner, checkin_list=runner.checkins)
    @runner = runner
    @checkin_list = checkin_list.sort {|a, b| a.checkin_time <=> b.checkin_time}
    
    # precompute some statistics
    @first_checkin_time = @checkin_list.first.checkin_time
    @last_checkin_time = @checkin_list.last.checkin_time
    
    @current_checkpoint = @checkin_list.last.checkpoint
  end
end
