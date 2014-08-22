class ActivitiesController < ApplicationController
  before_action :find_user, only: [:user_activity]

  def user_activity
    @activities = paginate @user.activities_performed
    render layout: nil if request.xhr?
  end

  private

    def find_user
      @user ||= User.find(id: params[:user_id])
    end
end
