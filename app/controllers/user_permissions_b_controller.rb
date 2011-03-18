class UserPermissionsBController < ApplicationController
  before_filter :require_admin_or_publisher

  def destroy
    @permission = UserPermissionB.where(:userID => params[:user_id], :datasetID => params[:id])
    @permission = @permission.where(:fileID => nil) if params[:type] == 'revoke'
    @permission.destroy_all

    redirect_to edit_user_path(params[:user_id])
  end
end
