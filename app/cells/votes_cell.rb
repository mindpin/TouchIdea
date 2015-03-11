class VotesCell < Cell::Rails
  helper :application

  def vote(option)
    @vote = option[:vote]
    @user = option[:user]
    render
  end

  def form(option)
    @vote = option[:vote]
    @user = option[:user]
    render
  end

  def show_form(option)
    @vote = option[:vote]
    @user = option[:user]
    render
  end
end