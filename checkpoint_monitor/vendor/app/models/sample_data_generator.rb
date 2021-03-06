class SampleDataGenerator
  def SampleDataGenerator.runner_ids
    ['RUBIN','TOMAS','RABIT','SEANM','SAMPL','IANKB','ARTMS','MYRNA','DAXTC'].concat(Range.new(100,999).map {|runner_num| "RN#{runner_num}"})
  end
  
  def SampleDataGenerator.initial_chaser_ids
    Range.new(1,9).map {|chaser_index| "CHSR#{chaser_index}"}
  end

  def SampleDataGenerator.get_near(cur_lng, cur_lat)
    lower_lat = 37.748950925423365
    lower_lng = -122.47627258300781
    upper_lat = 37.80430917687803
    upper_lng = -122.39091323852539
    
    lat_range = (upper_lat - lower_lat)/8
    lng_range = (upper_lng - lower_lng)/8
    
    new_lat = cur_lat + rand() * lat_range - lat_range/2
    new_lng = cur_lng + rand() * lng_range - lng_range/2
    while ((new_lat > upper_lat) || (new_lat < lower_lat)) do
      new_lat = cur_lat + rand() * lat_range - lat_range/2
    end
    while ((new_lng > upper_lng) || (new_lng < lower_lng)) do
      new_lng = cur_lng + rand() * lng_range - lng_range/2
    end
    
    return([new_lng, new_lat])
  end

  def SampleDataGenerator.bonus_checkpoints
    checkpoints = Checkpoint.find(:all, :conditions => "checkpoint_name like 'Sammy Bonus %'")

    if (checkpoints.size == 0)
      checkpoints = Range.new(1,2).map do |index|
        Checkpoint.create!(:checkpoint_name => "Sammy Bonus #{index}", :is_bonus => true, :checkpoint_id => index + 570, :checkpoint_position => nil)
      end
    end
    
    return(checkpoints)  
  end
      
  def SampleDataGenerator.mobile_checkpoints
    checkpoints = Checkpoint.find(:all, :conditions => "checkpoint_name like 'Sammy Mobile %'")

    if (checkpoints.size == 0)
      checkpoints = Range.new(1,2).map do |index|
        Checkpoint.create!(:checkpoint_name => "Sammy Mobile #{index}", :is_mobile => true, :checkpoint_id => index + 580, :checkpoint_position => nil)
      end
    end
    
    return(checkpoints)  
  end
      
  def SampleDataGenerator.checkpoints
    checkpoints = Checkpoint.find(:all, :conditions => "checkpoint_name like 'Sample %'")
    
    if (checkpoints.size == 0)
      checkpoints = []
      
      reg_lat = 37.794428
      reg_lng = -122.394782
      
      cur_lat = reg_lat
      cur_lng = reg_lng
      
      Range.new(0,8).map do |index|
        
        if (index == 0)
          c = Checkpoint.create!(:checkpoint_name => "Sample Registration", :checkpoint_id => index + 500, :checkpoint_loc_long => cur_lng, :checkpoint_loc_lat => cur_lat, :checkpoint_position => index)
          checkpoints << c
        else
          if (index <= 2)
            new_location = get_near(cur_lng, cur_lat)
            ca = Checkpoint.create!(:checkpoint_name => "Sample Checkpoint #{index}A", :checkpoint_id => index + 520 + 3, :checkpoint_loc_long => new_location[0], :checkpoint_loc_lat => new_location[1], :checkpoint_position => index)
            checkpoints << ca

            new_location = get_near(cur_lng, cur_lat)
            cb = Checkpoint.create!(:checkpoint_name => "Sample Checkpoint #{index}B", :checkpoint_id => index + 520 + 7, :checkpoint_loc_long => new_location[0], :checkpoint_loc_lat => new_location[1], :checkpoint_position => index)
            checkpoints << cb
            
            cur_lng = new_location[0]
            cur_lat = new_location[1]            
          else
            new_location = get_near(cur_lng, cur_lat)
            c = Checkpoint.create!(:checkpoint_name => "Sample Checkpoint #{index}", :checkpoint_id => index + 500, :checkpoint_loc_long => new_location[0], :checkpoint_loc_lat => new_location[1], :checkpoint_position => index)
            checkpoints << c
            
            cur_lng = new_location[0]
            cur_lat = new_location[1]                        
          end
        end
      end
    end
    
    return(checkpoints)  
  end
  
  def SampleDataGenerator.generate_early_data
    runners = runner_ids.map do |runner_id|
      if (runner_id =~ /^RN/)
        Runner.create!(:runner_id => runner_id)
      else
        Runner.create!(:runner_id => runner_id, :player_name => "Firstname #{runner_id}", :is_mugshot => true, :is_registered => true)
      end      
    end
      
    initial_chaser_ids.each do |chaser_id|
      Runner.create!(:runner_id => chaser_id, :player_name => "Starting Chaser #{chaser_id}", :is_mugshot => false)      
    end
    
    start_time = Time.new() - 86400
    
    chaser_id_map = Hash.new()
    initial_chaser_ids.each do |chaser_id|
      chaser_id_map[chaser_id] = start_time - 1
    end
    
    runners.each do |runner|
      puts "checking #{runner.runner_id}"
      runner_time = start_time - rand(3600)
      Checkin.create!(:runner => runner, :checkpoint => checkpoints[0], :checkin_time => runner_time)
      runner_time = start_time
      Range.new(1,4).each do |checkpoint_position|
        if (!chaser_id_map.include?(runner.runner_id))
          valid_checkpoints = Checkpoint.find(:all, :conditions => {:checkpoint_position => checkpoint_position})
          attempted_checkpoint = valid_checkpoints[rand(valid_checkpoints.size)]
          
          # this person is becoming a chaser
          if (rand() < 0.1)          
            puts " got tagged"
            # see if we will even record the catch
            if (rand() < 0.5)
              puts " we're recording it (tagging #{runner.inspect})"
              # figure out who they got caught by
              puts " someone from #{chaser_id_map.inspect}"
              already_chasers = chaser_id_map.keys.find_all{|key| chaser_id_map[key] < runner_time}
              puts " someone in #{already_chasers}"
              random_chaser_id = already_chasers[rand(already_chasers.size)]
              puts " #{random_chaser_id}"
        
              Tag.create!(:tagger_id => random_chaser_id, :runner_id => runner.runner_id, :tag_time => runner_time)
              puts " created tag"
              chaser = Runner.find(:first, :conditions => {:runner_id => random_chaser_id})
              puts " got chaser #{chaser.inspect}"
              if (chaser.present?)
                #chaser.update_attributes!(:is_tagged => true)
                ActiveRecord::Base.connection.execute("update runners set is_tagged = 1 where runner_id='#{chaser.runner_id}'")
                puts " chaser is marked"
              end
              #runner.update_attributes!(:is_tagged => true)
              ActiveRecord::Base.connection.execute("update runners set is_tagged = 1 where runner_id='#{runner.runner_id}'")
              puts " runner is marked"
            end
  
            chaser_id_map[runner.runner_id] = runner_time
          end
  
          runner_time = runner_time + rand(1800)
          Checkin.create!(:runner => runner, :checkpoint => attempted_checkpoint, :checkin_time => runner_time)
        end
      end
      
      # if not a chaser, 20% chance of visiting each mobile or bonus checkpoint
      if (!chaser_id_map.has_key?(runner.runner_id))
        SampleDataGenerator.bonus_checkpoints.concat(SampleDataGenerator.mobile_checkpoints).each do |checkpoint|
          if (rand() < 0.2)
            if (rand() < 0.5)
              checkin_time = start_time + (rand() * (runner_time - start_time)).round
            else
              checkin_time = runner_time + 600
            end
            Checkin.create!(:runner => runner, :checkpoint => checkpoint, :checkin_time => checkin_time)
          end
        end
      end      
    end
    
    return(chaser_id_map)
  end
  
  def SampleDataGenerator.generate_finishing_data(chaser_id_map)
    runners = runner_ids.map {|rid| Runner.find(:first, :conditions => {:runner_id => rid})}
    second_half_checkpoints = checkpoints.find_all{|cp| cp.checkpoint_position > 0 && cp.checkpoint_position > 4} 
    
    runners.find_all{|runner| !chaser_id_map.keys.include?(runner.runner_id)}.each do |runner|
      runner_time = runner.current_checkin.checkin_time
      second_half_checkpoints.each do |checkpoint|
        # this person is becoming a chaser
        if (rand() < 0.05)          
          puts " got tagged"
          # see if we will even record the catch
          if (rand() < 0.5)
            puts " we're recording it (tagging #{runner.inspect})"
            # figure out who they got caught by
            puts " someone from #{chaser_id_map.inspect}"
            already_chasers = chaser_id_map.keys.find_all{|key| chaser_id_map[key] < runner_time}
            puts " someone in #{already_chasers}"
            random_chaser_id = already_chasers[rand(already_chasers.size)]
            puts " #{random_chaser_id}"
      
            Tag.create!(:tagger_id => random_chaser_id, :runner_id => runner.runner_id, :tag_time => runner_time)
            puts " created tag"
            chaser = Runner.find(:first, :conditions => {:runner_id => random_chaser_id})
            puts " got chaser #{chaser.inspect}"
            if (chaser.present?)
              #chaser.update_attributes!(:is_tagged => true)
              ActiveRecord::Base.connection.execute("update runners set is_tagged = 1 where runner_id='#{chaser.runner_id}'")
              puts " chaser is marked"
            end
            #runner.update_attributes!(:is_tagged => true)
            ActiveRecord::Base.connection.execute("update runners set is_tagged = 1 where runner_id='#{runner.runner_id}'")
            puts " runner is marked"
          end

          chaser_id_map[runner.runner_id] = runner_time
        end

        runner_time = runner_time + rand(2400)
        Checkin.create!(:runner => runner, :checkpoint => checkpoint, :checkin_time => runner_time)
      end
    end 
    return(chaser_id_map)   
  end
  
  def SampleDataGenerator.delete_generated_data
    rids = runner_ids
    rids << initial_chaser_ids
    rids.each do |runner_id|
      ActiveRecord::Base.connection.execute("DELETE FROM tags where runner_id = '#{runner_id}' OR tagger_id = '#{runner_id}'")
      ActiveRecord::Base.connection.execute("DELETE FROM checkins where runner_id = '#{runner_id}'")
      ActiveRecord::Base.connection.execute("DELETE FROM runners where runner_id = '#{runner_id}'")
    end
    
    Checkpoint.find(:all, :conditions => "checkpoint_name like 'Sam%'").each do |checkpoint|
      ActiveRecord::Base.connection.execute("DELETE FROM checkpoints where checkpoint_name = '#{checkpoint.checkpoint_name}'")
    end      
  end
end
