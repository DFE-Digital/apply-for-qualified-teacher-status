module ErrorLog
  module LogErrors
    extend ActiveSupport::Concern
    include ActiveModel::Validations::Callbacks

    included do
      after_validation :log_errors

      def log_errors
        return if errors.empty?

        ValidationError.create!(
          form_object: self.class.name,
          messages: errors.messages,
          record:
        )
      end
    end
  end
end
