class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def cancellation_email(user)
    @user = user
    @url  = appointments_path
    mail(to: @user.email, subject: 'Your Appointment Was Cancelled By The Provider')
  end
end
