require 'session_countdown'
require 'test/unit'
require 'active_support/all'
require 'timecop'



# Since session in rails works like an hash, lets just subclass Hash for
# testing purposes.
class FakeSession < Hash
  include SessionCountdown
end



# Now we need a global 'session object' for the tests to look natural.
def session
  $session = $session || FakeSession.new
  return $session # you see what I'm doing?
end



class TestSessionCountdown < Test::Unit::TestCase


  def test_lots_o_stuff

    Timecop.freeze(Time.now)

    # start an unnamed session countdown 
    session.countdown_start(1.hour)

    assert_equal(1.hour, session.countdown_count)

    assert(session.countdown_running?)

    
    # one hour passes
    Timecop.freeze(Time.now + 1.hour)

    # countdown should be finished
    assert_equal(0, session.countdown_count)

    # which means session is expired
    assert session.countdown_expired?

    # of course it should no longer be running
    refute session.countdown_running? 

    # lets give it another go
    session.countdown_restart

    # should be running again
    assert session.countdown_running?

    # should be one hour, like before
    assert_equal(1.hour, session.countdown_count)

    # abort it
    session.countdown_abort

    # and its no longer running
    refute session.countdown_running?

    # but that doesn't mean its expired (no idea how to use this)
    refute session.countdown_expired?

  end



end
