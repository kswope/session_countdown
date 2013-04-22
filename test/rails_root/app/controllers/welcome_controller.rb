class WelcomeController < ApplicationController


  def index

    unless session.countdown_running?
      session.countdown_start(1.hour)
    else
      @countdown = session.countdown_count
    end

  end


end
