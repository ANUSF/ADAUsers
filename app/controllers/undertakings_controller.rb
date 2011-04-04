class UndertakingsController < ApplicationController
  before_filter :require_admin_or_owner

  def new
    @user = User.find(params[:user_id])
    @undertaking = Undertaking.new
    @datasets = AccessLevel.cat_a
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
      redirect_to @user, :notice => 'Thanks you! You should receive an email from us shortly.'
    else
      render :edit
    end
  end

end
