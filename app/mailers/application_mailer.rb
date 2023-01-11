class ApplicationMailer < Mail::Notify::Mailer
  default from: "qts.enquiries@education.gov.uk"

  after_action :store_observer_metadata

  def store_observer_metadata
    mailer_class_name = self.class.name.demodulize
    mailer_action_name = action_name
    application_form_id = application_form.id

    message.instance_variable_set(:@mailer_class_name, mailer_class_name)
    message.instance_variable_set(:@mailer_action_name, mailer_action_name)
    message.instance_variable_set(:@application_form_id, application_form_id)

    message.class.send(:attr_reader, :mailer_class_name)
    message.class.send(:attr_reader, :mailer_action_name)
    message.class.send(:attr_reader, :application_form_id)
  end
end
