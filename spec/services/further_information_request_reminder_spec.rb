# frozen_string_literal: true

require "rails_helper"

RSpec.describe FurtherInformationRequestReminder do
  describe ".call" do
    subject { described_class.call(further_information_request:) }

    shared_examples_for "an ignored FI request" do
      it "doesn't log any email" do
        expect { subject }.not_to(change { ReminderEmail.count })
      end

      it "doesn't send any email" do
        expect { subject }.to_not have_enqueued_mail(
          TeacherMailer,
          :further_information_request_reminder,
        )
      end
    end

    shared_examples_for "an FI request that triggers a reminder" do
      it "logs an email" do
        expect { subject }.to change {
          ReminderEmail.where(further_information_request:).count
        }.by(1)
      end

      it "sends an email" do
        expect { subject }.to have_enqueued_mail(
          TeacherMailer,
          :further_information_reminder,
        ).with(
          params: {
            teacher:,
            further_information_request:,
            due_date:,
          },
          args: [],
        )
      end
    end

    shared_examples_for "an FI request with less than two weeks remaining" do
      context "when no previous reminder has been sent" do
        it_behaves_like "an FI request that triggers a reminder"
      end

      context "when a previous reminder has been sent" do
        before { further_information_request.reminder_emails.create }

        it_behaves_like "an ignored FI request"
      end
    end

    shared_examples_for "an FI request with less than one week remaining" do
      context "when no previous reminder has been sent" do
        it_behaves_like "an FI request that triggers a reminder"
      end

      context "when one previous reminder has been sent" do
        before { further_information_request.reminder_emails.create }

        it_behaves_like "an FI request that triggers a reminder"
      end

      context "when two previous reminders have been sent" do
        before do
          2.times { further_information_request.reminder_emails.create }
        end

        it_behaves_like "an ignored FI request"
      end
    end

    shared_examples_for "an FI request with less than two days remaining" do
      context "when no previous reminder has been sent" do
        it_behaves_like "an FI request that triggers a reminder"
      end

      context "when one previous reminder has been sent" do
        before { further_information_request.reminder_emails.create }

        it_behaves_like "an FI request that triggers a reminder"
      end

      context "when two previous reminders have been sent" do
        before do
          2.times { further_information_request.reminder_emails.create }
        end

        it_behaves_like "an FI request that triggers a reminder"
      end
    end

    shared_examples_for "a request that is allowed 6 weeks to complete" do
      context "with less than two weeks remaining" do
        let(:further_information_requested_at) { (6.weeks - 13.days).ago }

        it_behaves_like "an FI request with less than two weeks remaining"
      end

      context "with less than one week remaining" do
        let(:further_information_requested_at) { (6.weeks - 5.days).ago }

        it_behaves_like "an FI request with less than one week remaining"
      end

      context "with one day remaining" do
        let(:further_information_requested_at) { (6.weeks - 47.hours).ago }

        it_behaves_like "an FI request with less than two days remaining"
      end
    end

    shared_examples_for "a request that is allowed 4 weeks to complete" do
      context "with less than two weeks remaining" do
        let(:further_information_requested_at) { (4.weeks - 13.days).ago }

        it_behaves_like "an FI request with less than two weeks remaining"
      end

      context "with less than one week remaining" do
        let(:further_information_requested_at) { (4.weeks - 5.days).ago }

        it_behaves_like "an FI request with less than one week remaining"
      end

      context "with one day remaining" do
        let(:further_information_requested_at) { (4.weeks - 47.hours).ago }

        it_behaves_like "an FI request with less than two days remaining"
      end
    end

    context "with a requested FI request" do
      let(:application_form) do
        create(:application_form, :submitted, :old_regs, region:)
      end
      let(:assessment) { create(:assessment, application_form:) }
      let(:region) { create(:region, :in_country, country_code: "FR") }
      let(:teacher) { application_form.teacher }

      let(:further_information_request) do
        create(
          :further_information_request,
          created_at: further_information_requested_at,
          assessment:,
        )
      end

      context "that allows 6 weeks to complete" do
        let(:due_date) do
          (further_information_request.created_at + 6.weeks).to_date
        end

        it_behaves_like "a request that is allowed 6 weeks to complete"
      end

      context "when the applicant is from a country with a 4 week expiry" do
        context "when created under the new regulations" do
          let(:application_form) do
            create(:application_form, :submitted, :new_regs, region:)
          end

          # Australia, Canada, Gibraltar, New Zealand, US
          %w[AU CA GI NZ US].each do |country_code|
            context "from country_code #{country_code}" do
              let(:region) { create(:region, :in_country, country_code:) }
              let(:due_date) do
                (further_information_request.created_at + 6.weeks).to_date
              end

              it_behaves_like "a request that is allowed 6 weeks to complete"
            end
          end
        end

        context "when not created under the new regulations" do
          # Australia, Canada, Gibraltar, New Zealand, US
          %w[AU CA GI NZ US].each do |country_code|
            context "from country_code #{country_code}" do
              let(:region) { create(:region, :in_country, country_code:) }
              let(:due_date) do
                (further_information_request.created_at + 4.weeks).to_date
              end

              it_behaves_like "a request that is allowed 4 weeks to complete"
            end
          end
        end
      end
    end

    context "with a received FI request" do
      let(:further_information_request) do
        create(:further_information_request, :received)
      end

      it_behaves_like "an ignored FI request"
    end

    context "with an expired FI request" do
      let(:further_information_request) do
        create(:further_information_request, :expired)
      end

      it_behaves_like "an ignored FI request"
    end
  end
end
