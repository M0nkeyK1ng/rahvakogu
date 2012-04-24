class HomeController < ApplicationController

  caches_action :index,
                :if => proc {|c| c.do_action_cache? },
                :cache_path => proc {|c| c.action_cache_path},
                :expires_in => 5.minutes

  def index
    @page_title = tr("Overview","home")
    @new_ideas = Idea.filtered.published.newest.limit(3)
    @top_ideas = Idea.filtered.published.top_rank.limit(3)
    @random_ideas = Idea.filtered.published.by_random.limit(3)

    all_ideas = []
    all_ideas += @new_ideas if @new_ideas
    all_ideas += @top_ideas if @top_ideas
    all_ideas += @random_ideas if @random_ideas

    @endorsements = nil
    if logged_in? # pull all their endorsements on the ideas shown
      @endorsements = current_user.endorsements.active.find(:all, :conditions => ["idea_id in (?)", all_ideas.collect {|c| c.id}])
    end

  end
end
