require 'rubygems'
require 'action_controller'


class NoCountdown < Exception; end



module SessionCountdown


  @@default_name = "default"


  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def countdown_start(delta, name = @@default_name)

    zero_time = Time.now + delta # when timer is done

    set_zero_time(zero_time, name) # save in session
    
    set_delta(delta, name) # needed for restarts, etc
    
  end



  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def countdown_running?(name = @@default_name)

    insist_countdown_exists(name)

    zero_time(name) && ( zero_time(name) > Time.now )

  end



  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def countdown_expired?(name = @@default_name)

    insist_countdown_exists(name)

    zero_time(name) && ! countdown_running?(name)

  end




  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def countdown_abort(name = @@default_name)

    insist_countdown_exists(name)

    set_zero_time(nil, name)

  end



  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def countdown_restart(name = @@default_name)

    insist_countdown_exists(name)

    new_zero_time = Time.now + delta(name)
    set_zero_time(new_zero_time, name)

  end



  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def countdown_count(name = @@default_name)

    insist_countdown_exists(name)

    remaining = zero_time(name) - Time.now
    (remaining > 0) ? remaining : 0

  end



  private #~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*



  #-----------------------------------------------------------------------------
  # 'namespaced' hash key
  #-----------------------------------------------------------------------------
  def zero_key(name)
    "session_countdown::#{name}"
  end



  #-----------------------------------------------------------------------------
  # 'namespaced' hash key
  #-----------------------------------------------------------------------------
  def delta_key(name)
    "session_countdown::#{name}_delta"
  end



  #-----------------------------------------------------------------------------
  # session hash accessor
  #-----------------------------------------------------------------------------
  def set_zero_time(time, name)
    self[zero_key(name)] = time 
  end



  #-----------------------------------------------------------------------------
  # session hash accessor
  #-----------------------------------------------------------------------------
  def zero_time(name)
    self[zero_key(name)] 
  end



  #-----------------------------------------------------------------------------
  # session hash accessor
  #-----------------------------------------------------------------------------
  def set_delta(delta, name)
    self[delta_key(name)] = delta
  end



  #-----------------------------------------------------------------------------
  # session hash accessor
  #-----------------------------------------------------------------------------
  def delta(name)
    self[delta_key(name)] 
  end



  #-----------------------------------------------------------------------------
  # A sanity check for timer name typos or other screwups.
  # Wishing ruby had decorators (faking it with method_missing too ugly)
  #-----------------------------------------------------------------------------
  def insist_countdown_exists(name)
    
    # We use delta_key here because timer might have been nil'd by aborting,
    # but there's will still be a delta
    # unless self[delta_key(name)]
    unless delta(name)
      raise NoCountdown, "no session countdown named '#{name}'"
    end

  end



end # module SessionCountdown



# stuff all the cool methods above into rail's session object
class ActionDispatch::Session::AbstractStore::SessionHash
  include SessionCountdown
end

