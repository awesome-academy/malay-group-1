class UserMailer < ApplicationMailer
  def account_activation user
    @user = user
    mail to: user.email, subject: t(".acct_active")
  end

  def password_reset user
    @user = user
    mail to: user.email, subject: t(".ps_reset_mess")
  end
end
