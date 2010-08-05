require 'rubygems'
require 'action_controller'


class NoCountdown < Exception; end

module SessionCountdown

  @@default_name = "default"

  def countdown_run(delta, name = @@default_name)
    self[get_zero_key(name)] = Time.now + delta
    self[get_zero_delta_key(name)] = delta # save for reset
  end

  def countdown_running?(name = @@default_name)
    self[get_zero_key(name)] && self[get_zero_key(name)] > Time.now
  end

  # sanity check for existing countdown for some methods
  def method_missing(method, *args)
    check_countdown_exists(*args) # reason for this method_missing()
    method = "_#{method}"
    respond_to?(method) ? send(method, *args) : raise(NoMethodError)
  end

  ## these methods all require a sanity check for existing countdown

  def _countdown_expire(name = @@default_name)
    self[get_zero_key(name)] = Time.now
  end

  def _countdown_expired?(name = @@default_name)
    ! countdown_running?(name)
  end

  def _countdown_restart(name = @@default_name)
    self[get_zero_key(name)] = Time.now + self[get_zero_delta_key(name)]
  end

  def _countdown_count(name = @@default_name)
    remaining = (self[get_zero_key(name)] - Time.now)
    (remaining > 0) ? remaining : 0
  end


  private #~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*


  def get_zero_key(name)
    "session_countdown:#{name}"
  end

  def get_zero_delta_key(name)
    "session_countdown:#{name}_delta"
  end

  def check_countdown_exists(name = @@default_name)
    unless self[get_zero_key(name)]
      raise NoCountdown, "no session countdown named '#{name}'"
    end
  end

end


if Rails::VERSION::MAJOR == 2

  class ActionController::Session::AbstractStore::SessionHash
    include SessionCountdown
  end

else

  class ActionDispatch::Session::AbstractStore::SessionHash
    include SessionCountdown
  end

end

