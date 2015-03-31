class FriendshipsController < ApplicationController
  def create
    current_user.friendships.create friendship_params
  end

  private
  def friendship_params
    params.require(:friendship).permit(:uid, :name)
  end
end

