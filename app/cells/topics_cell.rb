class TopicsCell < Cell::Rails
  helper :application

  def list(paged_votes, user, loading_url)
    @paged_votes = paged_votes
    @user = user
    @loading_url = loading_url
    render
  end

  def topic_options(vote_items, user)
    @vote_items = vote_items
    @user = user
    render
  end

  def infocard(vote)
    @vote = vote
    @infocard = @vote.infocard
    return '' if @infocard.blank?
    render
  end
end