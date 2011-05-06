class Admin::UserPermissionsBController < ApplicationController
  before_filter :require_admin
  layout 'ada_admin'

  def destroy
    @permission = UserPermissionB.where(:userID => params[:user_id], :datasetID => params[:id])
    @permission = @permission.where(:fileID => nil) if params[:type] == 'revoke'
    @permission.destroy_all

    redirect_to edit_admin_user_path(params[:user_id])
  end
end
