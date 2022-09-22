class ArrivalMailer < ApplicationMailer

  def forward_mail(arrival_msg)
    indention_point = arrival_msg.index('DT JDL')
    @second_msg     = arrival_msg.slice!(indention_point..-1).chomp
    @first_msg      = arrival_msg.chomp

    mail(from: Rails.application.credentials.gmail[:from],
         to:   Rails.application.credentials.gmail[:to])
  end

end
