# frozen_string_literal: true

module TeacherInterface
  class PaymentTransactionsController < BaseController
    before_action :load_application_form

    def show
      response = GovUKPay::Client::ReadPayment.call(
        payment_id: session[:gov_uk_pay_payment_id],
      )

      if response[:state]["status"] == "success"
        SubmitApplicationForm.call(application_form:, user: current_teacher)
        redirect_to %i[teacher_interface application_form]
      else
        flash[:alert] = "Payment failed, please try again."
        redirect_to edit_teacher_interface_application_form_path
      end
    end

    def create
      # At this stage to productionise, we'll probably look at
      # creating a new record under a payment_transactions table
      # which will then hold the payment_id returned and later on
      # used to track the status of the payment. For now, as part
      # of the spike, we will simply store that payment_id in the
      # user session.
      response = GovUKPay::Client::CreatePayment.call(
        amount: 1000,
        reference: application_form.reference,
        email: current_teacher.email
      )

      session[:gov_uk_pay_payment_id] = response[:payment_id]
      next_url = response[:_links]["next_url"]["href"]

      redirect_to next_url, allow_other_host: true
    end
  end
end
