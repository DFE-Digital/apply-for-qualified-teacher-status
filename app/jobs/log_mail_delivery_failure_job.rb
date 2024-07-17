class LogMailDeliveryFailureJob < ActionMailer::MailDeliveryJob
    def perform(*args)
      super 
    rescue => e
      
      record_failure(*args)
    end
  
    private
  
    def record_failure(*args)
      MailDeliveryFailure.create(
        email_address: 
        mailer_class: 
        mailer_action_method: 
      )
    end
  end
