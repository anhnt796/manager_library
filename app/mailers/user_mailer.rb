class UserMailer < ApplicationMailer
  def card_activation user
    @user = user
    mail to: user.email
  end

  def password_reset user
    @user = user
    mail to: user.email
  end
end
