class QuestionsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :js, only: [:create]

  def create
    @vote = Vote.find params[:vote_id]
    @user_ids = @vote.voted_users.map(&:id)
    @question = @vote.questions.new(question_params)
    if @question.save
      @vote.questions.each{|q| q.answers.new}
      @editor = current_user
    else
      render :new
    end
  end

  private
  def question_params
    params.require(:question).permit(:title, answers_attributes: [:id, :title, :questionr_id, :_destroy])
  end
end

