class UndertakingsController < ApplicationController
  before_filter :require_admin_or_owner

  def new
    @user = User.find(params[:user_id])
    @dataset_description = params[:dataset_description]

    if params.has_key? :datasetID
      @datasetID = params[:datasetID]
      @is_restricted = AccessLevel.dataset_is_restricted(@datasetID)
    else
      @is_restricted = params[:is_restricted] == '1'
    end

    @undertaking = Undertaking.new(:is_restricted => @is_restricted || false)
    @datasets = @is_restricted ? AccessLevel.ada_ddi.cat_b : AccessLevel.ada_ddi.cat_a
  end

  def create
    @user = User.find(params[:user_id])

    # AccessLevels have a composite primary key, so we can't look them up with :dataset_ids
    @undertaking_data = params[:undertaking]
    @undertaking_data[:datasets] = @undertaking_data[:dataset_ids].map { |id| AccessLevel.not_files.find_by_datasetID(id) } if @undertaking_data[:dataset_ids]
    @undertaking_data.delete(:dataset_ids)

    @undertaking = Undertaking.new(@undertaking_data)
    @undertaking.user = @user

    if @undertaking.save
      redirect_to edit_user_undertaking_path(@user, @undertaking)
    else
      flash.now[:alert] = 'Please check the values you filled in.'
      @new_undertaking = Undertaking.new
      @datasets = AccessLevel.cat_a
      render :new
    end
  end

  def edit
    @user = User.find(params[:user_id])
    @undertaking = Undertaking.find(params[:id])
  end

  def update
    @user = User.find(params[:user_id])
    @undertaking = Undertaking.find(params[:id])

    if @undertaking.update_attributes(params[:undertaking])
      if @undertaking.agreed
        UndertakingMailer.confirm_to_admin_email(self, @undertaking).deliver
        UndertakingMailer.confirm_to_user_email(self, @undertaking).deliver
      end
      redirect_to @user, :notice => 'Thank you! You should receive an email from us shortly.'
    else
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:user_id])
    @undertaking = Undertaking.find(params[:id])

    @undertaking.destroy

    redirect_to @user, :notice => 'Your undertaking has been cancelled.'
  end

end
