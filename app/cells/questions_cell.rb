class QuestionsCell < Cell::Rails
  helper :application

  def form(option)
    @vote = option[:vote]
    @user = option[:user]
    render
  end
end