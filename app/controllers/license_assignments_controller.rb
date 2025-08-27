class LicenseAssignmentsController < ApplicationController
  before_action :set_account
  before_action :set_license_assignment, only: [:destroy]

  # GET /accounts/:account_id/license_assignments
  def index
    @products_with_subscriptions = @account.products.includes(:subscriptions, :license_assignments)
                                            .joins(:subscriptions)
                                            .where(subscriptions: { account_id: @account.id })
    @users = @account.users.includes(:license_assignments)
    @license_assignments = @account.license_assignments.includes(:user, :product)
  end

  # POST /accounts/:account_id/license_assignments
  def create
    action = params[:commit] # This will contain the button text/value

    if action == "assign"
      handle_assign_licenses
    elsif action == "unassign"
      handle_unassign_licenses
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to account_license_assignments_path(@account) }
    end
  end

  # DELETE /accounts/:account_id/license_assignments/:id
  def destroy
    @license_assignment.destroy
    flash[:notice] = "License assignment removed successfully."

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to account_license_assignments_path(@account) }
    end
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def set_license_assignment
    @license_assignment = @account.license_assignments.find(params[:id])
  end

  def handle_assign_licenses
    @license_assignment_service = Licenses::AssignmentService.run(
      account: @account,
      user_ids: params[:user_ids],
      product_ids: params[:product_ids]
    )

    @updated_licenses = @license_assignment_service.result&.compact

    if @license_assignment_service.errors.any?
      flash[:alert] = @license_assignment_service.errors.full_messages.join("\n")
    else
      flash[:notice] = "Licenses assigned successfully."
    end
  end

  def handle_unassign_licenses
    @license_unassignment_service = Licenses::UnassignmentService.run(
      account: @account,
      user_ids: params[:user_ids],
      product_ids: params[:product_ids]
    )

    @updated_licenses = @license_unassignment_service.result&.compact

    if @license_unassignment_service.errors.any?
      flash[:alert] = @license_unassignment_service.errors.full_messages.join("\n")
    else
      flash[:notice] = "Licenses unassigned successfully."
    end

  end
end
