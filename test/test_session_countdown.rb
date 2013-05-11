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
  return $session # global masquerading as something else)
end



class TestSessionCountdown < Test::Unit::TestCase



  def setup

    # need to zero out the bogus session between tests
    $session = nil

  end



  def test_big_sequence_of_stuff

    Timecop.freeze(Time.now)

    # start an unnamed session countdown 
    session.countdown_start(1.hour)

    # the time left should be 1 hour
    assert_equal(1.hour, session.countdown_count)

    # and the timer should be running
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



  def test_multiple_timers

    Timecop.freeze(Time.now)

    # start two named session countdowns
    session.countdown_start(1.hour, :a)
    session.countdown_start(1.hour, :b)

    # the times left should be 1 hour
    assert_equal(1.hour, session.countdown_count(:a))
    assert_equal(1.hour, session.countdown_count(:b))

    # and the timers should be running
    assert(session.countdown_running?(:a))
    assert(session.countdown_running?(:b))
    
    # one hour passes
    Timecop.freeze(Time.now + 1.hour)

    # countdown should be finished
    assert_equal(0, session.countdown_count(:a))
    assert_equal(0, session.countdown_count(:b))

    # restarting one timer only
    session.countdown_restart(:a)

    # and only one timer should be running
    assert(session.countdown_running?(:a))
    refute(session.countdown_running?(:b))

    # jump ahead 30 minutes
    Timecop.freeze(Time.now + 30.minutes)

    # timer :a should be down to half an hour
    assert_equal(30.minutes, session.countdown_count(:a))

    # timer :b should still be done
    assert_equal(0.minutes, session.countdown_count(:b))

    # restart :b, and now :a should be half that of :b
    session.countdown_restart(:b)
    assert_equal(30.minutes, session.countdown_count(:a))
    assert_equal(60.minutes, session.countdown_count(:b))

  end



end
