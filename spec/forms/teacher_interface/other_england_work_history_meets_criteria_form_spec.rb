# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::OtherEnglandWorkHistoryMeetsCriteriaForm,
               type: :model do
  subject(:form) do
    described_class.new(application_form:, has_other_england_work_history:)
  end

  let(:application_form) { build(:application_form) }

  describe "validations" do
    let(:has_other_england_work_history) { "" }

    it { is_expected.to validate_presence_of(:application_form) }

    it do
      expect(subject).to allow_values(true, false).for(
        :has_other_england_work_history,
      )
    end
  end

  describe "#save" do
    context "when has_other_england_work_history is true" do
      let(:has_other_england_work_history) { "true" }

      it "saves the application form" do
        form.save(validate: true)

        expect(application_form.has_other_england_work_history).to be(true)
      end

      context "with existing other England work experiences" do
        before do
          create(:work_history, application_form:)
          create(:work_history, :other_england_role, application_form:)
        end

        it "does not destroy any existing other educational roles in England" do
          expect { form.save(validate: true) }.not_to change(
            application_form.work_histories,
            :count,
          )
        end
      end
    end

    context "when has_other_england_work_history is false" do
      let(:has_other_england_work_history) { "false" }

      it "saves the application form" do
        form.save(validate: true)

        expect(application_form.has_other_england_work_history).to be(false)
      end

      context "with existing other England work experiences" do
        before do
          create(:work_history, application_form:)
          create(:work_history, :other_england_role, application_form:)
        end

        it "destroys any existing other educational roles in England" do
          expect { form.save(validate: true) }.to change(
            application_form.work_histories,
            :count,
          ).by(-1)
        end
      end
    end
  end
end
