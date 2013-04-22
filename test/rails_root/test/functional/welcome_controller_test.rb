require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  test "the truth" do


    ### ripped this off from ../../../test_session_countdown.rb


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






    assert true
  end
end
