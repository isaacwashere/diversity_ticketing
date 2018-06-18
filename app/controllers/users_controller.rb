require "report_exporter"

class UsersController < Clearance::UsersController
  before_action :ensure_correct_user, only: [:show, :edit, :update, :destroy, :applications, :delete_account]

  def show
    @categorized_user_events = {
      approved: @user.events.approved.upcoming,
      unapproved: @user.events.unapproved.upcoming,
      past: @user.events.past
    }
    render "users/events"
  end

  def create
    @user = user_from_params
    if @user.save
      sign_in @user
      unless params[:referer].include?('continue_as_guest')
        redirect_to root_path
      else
        redirect_to new_event_application_path(params[:event_id])
      end
    else
      render template: "users/new"
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.csv { send_data ReportExporter.user_data(@user), filename: "user_data_#{DateTime.now.strftime("%F")}.csv" }
    end
  end

  def update
    if user_params[:password] === ''
      flash[:error] = "Password is a mandatory field"
      redirect_to edit_user_path(@user)
    elsif @user.authenticated?(params[:user][:password])
      if @user.update(user_params) && params[:commit] == "Delete account"
        redirect_to delete_account_path(@user)
      elsif @user.update(user_params)
        if user_params[:new_password] != ''
          @user.update_attributes(password: user_params[:new_password])
        end
        redirect_to edit_user_path(@user), notice: "You have successfully updated your user data."
      else
      render :edit
      end
    else
      flash[:error] = "Incorrect password"
      redirect_to edit_user_path(@user)
    end
  end

  def destroy
    if @user.destroy
      flash[:alert] = "Your Account has been deleted successfully."
      redirect_to root_path
    else
      render :edit
    end
  end

  def delete_account
    if request.env["HTTP_REFERER"] != edit_user_url(@user)
      redirect_to root_path, alert: "We're sorry. You don't have permission to access this page."
    end
  end

  def applications
    @categorized_user_applications = {
      submitted: @user.applications.submitted,
      drafts: @user.applications.drafts,
    }
  end

  private
    def ensure_correct_user
      @user = User.find(params[:id])
      unless @user == current_user
        redirect_to root_path, alert: "We're sorry. You don't have permission to access this page."
      end
    end

    def user_params
      params.require(:user).permit(:name, :email, :password, :new_password, :country, :country_email_notifications)
    end

    def user_from_params
      name = user_params.delete(:name)
      email = user_params.delete(:email)
      password = user_params.delete(:password)

      Clearance.configuration.user_model.new(user_params).tap do |user|
        user.name = name
        user.email = email
        user.password = password
      end
    end
end
