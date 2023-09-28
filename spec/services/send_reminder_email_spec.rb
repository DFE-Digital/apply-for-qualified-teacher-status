# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendReminderEmail do
  describe "#call" do
    subject(:call) { described_class.call(remindable:) }

    shared_examples "doesn't send an email" do
      it "doesn't log any email" do
        expect { call }.not_to change(ReminderEmail, :count)
      end

      it "doesn't send any email" do
        expect { call }.to_not have_enqueued_mail
      end
    end

    shared_examples "sends an email" do
      it "logs an email" do
        expect { call }.to change { ReminderEmail.where(remindable:).count }.by(
          1,
        )
      end
    end

    shared_examples "sends a further information reminder email" do
      include_examples "sends an email"

      it "sends an email" do
        expect { call }.to have_enqueued_mail(
          TeacherMailer,
          :further_information_reminder,
        ).with(
          params: {
            teacher:,
            further_information_request: remindable,
          },
          args: [],
        )
      end
    end

    shared_examples "sends a reference reminder email" do
      include_examples "sends an email"

      it "sends an email" do
        expect { subject }.to have_enqueued_mail(
          RefereeMailer,
          :reference_reminder,
        ).with(params: { reference_request: remindable }, args: [])
      end
    end

    shared_examples "sends an application not submitted email" do
      include_examples "sends an email"

      it "sends an email" do
        expect { subject }.to have_enqueued_mail(
          TeacherMailer,
          :application_not_submitted,
        ).with(
          params: {
            teacher: remindable.teacher,
            number_of_reminders_sent: a_kind_of(Integer),
          },
          args: [],
        )
      end
    end

    shared_examples "first reminder email" do |shared_example|
      context "when no previous reminder has been sent" do
        include_examples shared_example
      end

      context "when a previous reminder has been sent" do
        before { remindable.reminder_emails.create }
        include_examples "doesn't send an email"
      end

      context "when two previous reminders have been sent" do
        before { 2.times { remindable.reminder_emails.create } }
        include_examples "doesn't send an email"
      end
    end

    shared_examples "second reminder email" do |shared_example|
      context "when no previous reminder has been sent" do
        include_examples shared_example
      end

      context "when one previous reminder has been sent" do
        before { remindable.reminder_emails.create }
        include_examples shared_example
      end

      context "when two previous reminders have been sent" do
        before { 2.times { remindable.reminder_emails.create } }
        include_examples "doesn't send an email"
      end
    end

    shared_examples "third reminder email" do |shared_example|
      context "when no previous reminder has been sent" do
        include_examples shared_example
      end

      context "when one previous reminder has been sent" do
        before { remindable.reminder_emails.create }
        include_examples shared_example
      end

      context "when two previous reminders have been sent" do
        before { 2.times { remindable.reminder_emails.create } }
        include_examples shared_example
      end
    end

    context "with a draft application form" do
      let(:remindable) do
        create(:application_form, :draft, created_at: application_created_at)
      end

      context "with less than two weeks remaining" do
        let(:application_created_at) { (6.months - 13.days).ago }
        include_examples "first reminder email",
                         "sends an application not submitted email"
      end

      context "with less than one week remaining" do
        let(:application_created_at) { (6.months - 1.day).ago }
        include_examples "second reminder email",
                         "sends an application not submitted email"
      end
    end

    context "with a submitted application form" do
      let(:remindable) { create(:application_form, :submitted) }
      include_examples "doesn't send an email"
    end

    shared_examples_for "an FI request that is allowed 6 weeks to complete" do
      context "with less than two weeks remaining" do
        let(:further_information_requested_at) { (6.weeks - 13.days).ago }
        include_examples "first reminder email",
                         "sends a further information reminder email"
      end

      context "with less than one week remaining" do
        let(:further_information_requested_at) { (6.weeks - 5.days).ago }
        include_examples "second reminder email",
                         "sends a further information reminder email"
      end

      context "with one day remaining" do
        let(:further_information_requested_at) { (6.weeks - 47.hours).ago }
        include_examples "third reminder email",
                         "sends a further information reminder email"
      end
    end

    shared_examples_for "an FI request that is allowed 4 weeks to complete" do
      context "with less than two weeks remaining" do
        let(:further_information_requested_at) { (4.weeks - 13.days).ago }
        include_examples "first reminder email",
                         "sends a further information reminder email"
      end

      context "with less than one week remaining" do
        let(:further_information_requested_at) { (4.weeks - 5.days).ago }
        include_examples "second reminder email",
                         "sends a further information reminder email"
      end

      context "with one day remaining" do
        let(:further_information_requested_at) { (4.weeks - 47.hours).ago }
        include_examples "third reminder email",
                         "sends a further information reminder email"
      end
    end

    context "with a requested FI request" do
      let(:application_form) do
        create(:application_form, :submitted, :old_regs, region:)
      end
      let(:assessment) { create(:assessment, application_form:) }
      let(:region) { create(:region, :in_country, country_code: "FR") }
      let(:teacher) { application_form.teacher }

      let(:remindable) do
        create(
          :further_information_request,
          requested_at: further_information_requested_at,
          assessment:,
        )
      end

      context "that allows 6 weeks to complete" do
        it_behaves_like "an FI request that is allowed 6 weeks to complete"
      end

      context "when the applicant is from a country with a 4 week expiry" do
        context "when created under the new regulations" do
          let(:application_form) do
            create(:application_form, :submitted, region:)
          end

          # Australia, Canada, Gibraltar, New Zealand, US
          %w[AU CA GI NZ US].each do |country_code|
            context "from country_code #{country_code}" do
              let(:region) { create(:region, :in_country, country_code:) }

              it_behaves_like "an FI request that is allowed 6 weeks to complete"
            end
          end
        end

        context "when not created under the new regulations" do
          # Australia, Canada, Gibraltar, New Zealand, US
          %w[AU CA GI NZ US].each do |country_code|
            context "from country_code #{country_code}" do
              let(:region) { create(:region, :in_country, country_code:) }

              it_behaves_like "an FI request that is allowed 4 weeks to complete"
            end
          end
        end
      end
    end

    context "with a received FI request" do
      let(:remindable) do
        create(
          :further_information_request,
          :received,
          requested_at: Time.zone.now,
        )
      end
      include_examples "doesn't send an email"
    end

    context "with an expired FI request" do
      let(:remindable) do
        create(
          :further_information_request,
          :expired,
          requested_at: Time.zone.now,
        )
      end
      include_examples "doesn't send an email"
    end

    context "with a requested reference request" do
      let(:application_form) do
        create(:application_form, :submitted, :old_regs, region:)
      end
      let(:assessment) { create(:assessment, application_form:) }
      let(:region) { create(:region, :in_country, country_code: "FR") }
      let(:work_history) { remindable.work_history }

      let(:remindable) do
        create(
          :reference_request,
          requested_at: reference_requested_at,
          assessment:,
        )
      end

      context "with less than four weeks remaining" do
        let(:reference_requested_at) { (6.weeks - 27.days).ago }
        include_examples "first reminder email",
                         "sends a reference reminder email"
      end

      context "with less than two weeks remaining" do
        let(:reference_requested_at) { (6.weeks - 13.days).ago }
        include_examples "second reminder email",
                         "sends a reference reminder email"
      end
    end

    context "with a received reference request" do
      let(:remindable) do
        create(:reference_request, :received, requested_at: Time.zone.now)
      end
      include_examples "doesn't send an email"
    end

    context "with an expired reference request" do
      let(:remindable) do
        create(:reference_request, :expired, requested_at: Time.zone.now)
      end
      include_examples "doesn't send an email"
    end
  end
end
