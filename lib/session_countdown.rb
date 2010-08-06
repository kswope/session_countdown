require 'rubygems'
require 'action_controller'


class NoCountdown < Exception; end

module SessionCountdown

  @@default_name = "default"

  def countdown_start(delta, name = @@default_name)
    self[get_zero_key(name)] = Time.now + delta
    self[get_zero_delta_key(name)] = delta # save for reset
  end

  def countdown_running?(name = @@default_name)
    self[get_zero_key(name)] && self[get_zero_key(name)] > Time.now
  end

  def countdown_expired?(name = @@default_name)
    self[get_zero_key(name)] && ! countdown_running?(name)
  end

  # sanity checkpoint for some methods, checking for existing countdown
  def method_missing(method, *args)

    method = "_#{method}" # super secret shadow method

    # first check if method exists
    raise NoMethodError unless respond_to?(method)

    # check if specified countdown timer exists - reason for this method_missing
    insist_countdown_exists(*args)

    # finally run method
    send(method, *args)

  end

  ## these methods all require a sanity check for existing countdown

  def _countdown_abort(name = @@default_name)
    self[get_zero_key(name)] = nil
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

  def insist_countdown_exists(name = @@default_name)
    # We use delta_key here because timer might have been nil'd by
    # aborting, but it still should be restartable.
    unless self[get_zero_delta_key(name)]
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

