class ArrivalMailer < ApplicationMailer

  def forward_mail(arrival_msg)
    @arrival_msg = arrival_msg

    mail(from: Rails.application.credentials.gmail[:from],
         to:   Rails.application.credentials.gmail[:to])
  end

end
