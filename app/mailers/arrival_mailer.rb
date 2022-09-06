class ArrivalMailer < ApplicationMailer

  def forward_mail(arrival_msg)
    @arrival_msg = arrival_msg[0]

    mail(from: Rails.application.credentials.mail[:from],
         to:   Rails.application.credentials.mail[:to])
  end

end
