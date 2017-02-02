class AppointmentsController < ApplicationController
  def index
    if session[:provider_id]
      @appointments = Appointment.where(provider: current_user)
    else
      @appointments = Appointment.all
    end
  end

  def show
    @appointment = Appointment.find(params[:id])
    @provider = @appointment.provider
  end

  def new
    if signed_in_provider
      @appointment = Appointment.new
    else
      flash[:notice] = "Sorry, you can't create new appointments"
      redirect_to appointments_path
    end
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @provider = current_user
    @appointment.provider = @provider
    if @appointment.save
      flash[:notice] = "Appointment Created"
      redirect_to @provider
    else
      flash[:notice] = @appointment.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
    @appointment = Appointment.find(params[:id])
    @provider = current_provider
  end

  def update
    @appointment = Appointment.find(params[:id])
    if signed_in_provider
      @provider = current_user
      if @appointment.update
        flash[:notice] = "Appointment Updated"
        redirect_to @provider
      else
        flash[:notice] = @appointment.errors.full_messages.to_sentence
        render :edit
      end
    elsif signed_in_user
      if @appointment.booked? && @appointment.user == current_user
        @appointment.unbook!
        if @appointment.update({user: nil, booked?: false})
          flash[:notice] = "Appointment Canceled"
          redirect_to @appointment
        else
          render :show
        end
      elsif !@appointment.booked?
        @appointment.book!(current_user)
        if @appointment.update({user: current_user, booked?: true})
          flash[:notice] = "Appointment Booked!"
          redirect_to @appointment
        else
          render :show
        end
      end
    end
  end

  def destroy
    @appointment = Appointment.find(params[:id])
    @provider = current_user
    if @appointment.destroy
      flash[:notice] = "Appointment Removed"
      redirect_to @provider
    else
      flash[:notice] = "Something went wrong"
      render :index
    end
  end

  private

  def appointment_params
    params.require(:appointment).permit(
      :date,
      :start_time,
      :end_time,
      :booked?
    )
  end
end
