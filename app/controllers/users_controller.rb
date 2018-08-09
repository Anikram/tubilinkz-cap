class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def show
    @total_links_count = @user.links.count
    @recent_links = @user.links.order(created_at: :desc).limit(20)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
