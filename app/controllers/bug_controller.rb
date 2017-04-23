class BugController < ApplicationController
  def index
    @bugs = Bug.search(params)
  end
end
