class UsersController < ApplicationController
  before_action :set_account
  before_action :set_user, only: %i[ edit update destroy ]

  # GET /accounts/:account_id/users
  def index
    @users = @account.users.includes(:account_users)
  end

  # GET /accounts/:account_id/users/new
  def new
    @user = User.new
  end

  # POST /accounts/:account_id/users
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        # Create the account_user relationship
        @account.account_users.create!(user: @user, roles: { member: true })
        format.html { redirect_to account_users_path(@account), notice: "User was successfully added to the account." }
        format.json { render :show, status: :created, location: [@account, @user] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /accounts/:account_id/users/:id/edit
  def edit
  end

  # PATCH/PUT /accounts/:account_id/users/:id
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to account_users_path(@account), notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: [@account, @user] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/:account_id/users/:id
  def destroy
    begin
      # Remove the user from this specific account
      account_user = @account.account_users.find_by(user: @user)
      if account_user
        account_user.destroy!

        # If user is not associated with any other accounts, delete the user completely
        if @user.accounts.empty?
          @user.destroy!
          message = "User was successfully deleted."
        else
          message = "User was successfully removed from the account."
        end
      else
        message = "User is not associated with this account."
      end

      respond_to do |format|
        format.html { redirect_to account_users_path(@account), notice: message }
        format.json { head :no_content }
      end
    rescue ActiveRecord::InvalidForeignKey => e
      respond_to do |format|
        format.html { redirect_to account_users_path(@account), alert: "Cannot delete user: they have active license assignments. Please unassign all licenses first." }
        format.json { render json: { error: "Cannot delete user with active license assignments" }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def set_user
    @user = @account.users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
