require 'test_helper'
require 'timecop'

class TestControllerTest < ActionController::TestCase


  test "fantasy/typo methods" do

    assert_raise(NoMethodError) { session.countdown_banana }
    assert_raise(NoMethodError) { session.countdown_banana(123) }

  end


  test "single default" do

    assert ! session.countdown_running?
    assert ! session.countdown_expired?

    session.countdown_start(1.minute)
    assert session.countdown_running?
    assert ! session.countdown_expired?

    session.countdown_abort

    assert ! session.countdown_running?
    assert ! session.countdown_expired?

    session.countdown_restart
    assert ! session.countdown_expired?
    assert session.countdown_running?

  end


  test "truth table test" do

    # with no countdown started these conditions should be met
    assert ! session.countdown_running?
    assert ! session.countdown_expired?

    # with countdown started
    session.countdown_start(1.minute)
    assert session.countdown_running?
    assert ! session.countdown_expired?

    # with countdown expired
    session.countdown_abort
    assert ! session.countdown_running?
    assert ! session.countdown_expired?

  end


  test "mixed names" do

    ## start up two counters

    session.countdown_start(1.minute)
    session.countdown_start(1.minute, :admin)

    ## abort default counter

    assert session.countdown_running?
    session.countdown_abort
    assert ! session.countdown_running?
    assert ! session.countdown_expired?

    ## abort admin counter

    assert session.countdown_running?(:admin)
    session.countdown_abort(:admin)
    assert ! session.countdown_running?(:admin)
    assert ! session.countdown_expired?(:admin)

    ## mixing calls to both timers

    session.countdown_start(1.minute)
    assert session.countdown_running?()
    assert ! session.countdown_running?(:admin)
    session.countdown_abort
    assert ! session.countdown_expired?(:admin)
    session.countdown_restart(:admin)
    assert session.countdown_running?(:admin)
    assert ! session.countdown_expired?(:admin)
    assert ! session.countdown_running?()

  end


  test "expiring and resetting" do

    session.countdown_start(1.minute)
    assert session.countdown_running?
    assert ! session.countdown_expired?

    Timecop.travel(1.minute)
    assert ! session.countdown_running?
    assert session.countdown_expired?

    session.countdown_restart
    assert session.countdown_running?

    Timecop.return

  end


  test "named expiring and resetting" do

    session.countdown_start(1.minute, :admin)
    assert session.countdown_running?(:admin)
    assert ! session.countdown_expired?(:admin)

    Timecop.travel(1.minute)
    assert ! session.countdown_running?(:admin)
    assert session.countdown_expired?(:admin)

    session.countdown_restart(:admin)
    assert session.countdown_running?(:admin)

    Timecop.return

  end


  test "unstable state" do

    # restart, expire and count require an existing countdown, should
    # throw exception if there isn't one

    assert_raise(NoCountdown) { session.countdown_abort }
    assert_raise(NoCountdown) { session.countdown_restart }
    assert_raise(NoCountdown) { session.countdown_count }

    ## try with named countdown

    assert_raise(NoCountdown) { session.countdown_abort(:admin) }
    assert_raise(NoCountdown) { session.countdown_restart(:admin) }
    assert_raise(NoCountdown) { session.countdown_count(:admin) }

  end


  test "countdown_count" do

    session.countdown_start(1.minute)
    assert session.countdown_count < 1.minute
    assert session.countdown_count > (1.minute - 1)
    Timecop.travel(30.seconds)
    assert session.countdown_count < 30
    Timecop.travel(1.minute)
    assert session.countdown_count == 0

    session.countdown_restart
    assert session.countdown_count > (1.minute - 1)

    Timecop.return

  end


  # copied from README, mostly checking spelling
  test "rdoc example" do

    session.countdown_start(1.hour)
    assert (3599 < session.countdown_count)
    assert session.countdown_running?
    Timecop.travel(60.minute)
    assert_equal 0, session.countdown_count
    assert ! session.countdown_running?
    assert session.countdown_expired?
    session.countdown_restart
    assert session.countdown_running?
    session.countdown_abort
    assert ! session.countdown_running?
    assert ! session.countdown_expired?

  end

end
