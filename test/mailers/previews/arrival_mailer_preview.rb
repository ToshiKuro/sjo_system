# Preview all emails at http://localhost:3000/rails/mailers/arrival_mailer
class ArrivalMailerPreview < ActionMailer::Preview

  def arrival
    arrival_msg = ArrivalInformation.get_arrival_information
    ArrivalMailer.forward_mail(arrival_msg)
  end

end
