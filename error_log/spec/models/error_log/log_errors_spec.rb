require "rails_helper"

module ErrorLog
  RSpec.describe "LogErrors" do
    subject(:save) { form.save }

    let(:form) { UserForm.new(name:, record:) }
    let(:record) { Example.create }

    context "when the form is invalid" do
      let(:name) { nil }

      it "logs a validation error" do
        expect { save }.to change(ValidationError, :count).by(1)
      end

      it "records all the validation error messages" do
        save
        expect(ValidationError.last.messages).to include(
          "name" => ["can't be blank"]
        )
      end
    end

    context "when the form is valid" do
      let(:name) { "Test Name" }

      it "doesn't log a validation error" do
        expect { save }.not_to change(ValidationError, :count)
      end
    end

    context "when the record is missing" do
      let(:name) { nil }
      let(:record) { nil }

      it "raises an error" do
        expect { save }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
