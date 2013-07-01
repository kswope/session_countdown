require 'action_controller'


class NoCountdown < Exception; end



module SessionCountdown



  @@default_name = "default"


  #-----------------------------------------------------------------------------
  # Required to start a countdown.  The delta is how long the countdown is, in
  # seconds, and the name allows multiple countdowns to be created.
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

    ( zero_time(name) && ( zero_time(name) > Time.now ) ) ? true : false

  end



  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def countdown_expired?(name = @@default_name)

    ( zero_time(name) && ! countdown_running?(name) ) ? true : false

  end



  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def countdown_abort(name = @@default_name)

    set_zero_time(nil, name)

  end



  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def countdown_restart(name = @@default_name)

    new_zero_time = Time.now + delta(name)
    set_zero_time(new_zero_time, name)

  end



  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def countdown_count(name = @@default_name)

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








end # module SessionCountdown



ActiveSupport.on_load :action_controller do
  Rack::Session::Abstract::SessionHash.send :include, SessionCountdown # testing
  ActionDispatch::Request::Session.send :include, SessionCountdown
end

