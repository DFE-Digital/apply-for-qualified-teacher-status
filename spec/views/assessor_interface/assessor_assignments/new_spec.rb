# frozen_string_literal: true

require "rails_helper"

RSpec.describe "assessor_interface/assessor_assignments/new.html.erb", type: :view do
  subject { render }

  let(:application_form) { create(:application_form) }
  let(:staff) { create(:staff) }
  let(:form_object) do
    AssessorInterface::AssessorAssignmentForm.new(
      application_form: application_form,
      staff: staff
    )
  end

  before do
    assign(:application_form, application_form)
    assign(:form, form_object)
  end

  it do
    expect(subject).to include("Select") 
  end
end
