# lib/email_log_interceptor.rb

class EmailLogInterceptor
      MailDeliveryFailure.create!(
        email_address: email_address,
        mailer_class: mailer_class,
        mailer_action_method: mailer_action_method,
        error_message: error.message
      )
  end
  