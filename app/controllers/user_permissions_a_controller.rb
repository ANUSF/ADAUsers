class UserPermissionsAController < ApplicationController
  def destroy
    # TODO: Check that current_user owns this permission. Something like:
    # @permission = current_user.permissions_a.find(params[:id])
    @permission = UserPermissionA.find(params[:user_id], params[:id])
    @permission.destroy

    redirect_to edit_user_path(params[:user_id])
  end
end
