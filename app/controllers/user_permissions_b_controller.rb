class UserPermissionsBController < ApplicationController
  def destroy
    # TODO: Check that current_user owns this permission. Something like:
    # @permission = current_user.permissions_b.find(params[:id])

    @permission = UserPermissionB.where(:userID => params[:user_id], :datasetID => params[:id])
    @permission = @permission.where(:fileID => nil) if params[:type] == 'revoke'
    @permission.destroy_all

    redirect_to edit_user_path(params[:user_id])
  end
end