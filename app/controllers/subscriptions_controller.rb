class SubscriptionsController < ApplicationController
  before_action :set_account
  before_action :set_subscription, only: [:show, :edit, :update, :destroy]

  def index
    @subscriptions = @account.subscriptions.includes(:product)
    @products = Product.all
  end

  def show
  end

  def new
    @subscription = @account.subscriptions.build
    @products = Product.all
  end

  def create
    @subscription = @account.subscriptions.build(subscription_params)

    if @subscription.save
      flash[:notice] = "Subscription created successfully."
      redirect_to account_subscriptions_path(@account)
    else
      @products = Product.all
      render :new
    end
  end

  def edit
    @products = Product.all
  end

  def update
    if @subscription.update(subscription_params)
      flash[:notice] = "Subscription updated successfully."
      redirect_to account_subscriptions_path(@account)
    else
      @products = Product.all
      render :edit
    end
  end

  def destroy
    if @subscription.destroy
      flash[:notice] = "Subscription deleted successfully."
    else
      flash[:alert] = "Failed to delete subscription."
    end
    redirect_to account_subscriptions_path(@account)
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Account not found."
    redirect_to accounts_path
  end

  def set_subscription
    @subscription = @account.subscriptions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Subscription not found."
    redirect_to account_subscriptions_path(@account)
  end

  def subscription_params
    params.require(:subscription).permit(:product_id, :number_of_licenses, :issued_at, :expires_at)
  end
end
