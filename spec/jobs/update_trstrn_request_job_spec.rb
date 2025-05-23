# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateTRSTRNRequestJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(trs_trn_request) }

    let(:application_form) { trs_trn_request.application_form }
    let(:teacher) { application_form.teacher }
    let(:trn) { "abcdef" }

    # rubocop:disable Lint/SuppressedException
    let(:perform_rescue_exception) do
      perform
    rescue StandardError
    end
    # rubocop:enable Lint/SuppressedException

    around { |example| freeze_time { example.run } }

    context "with an initial request" do
      let(:trs_trn_request) { create(:trs_trn_request, :initial) }

      context "with a successful response" do
        before do
          allow(TRS::Client::V3::CreateTRNRequest).to receive(:call).and_return(
            {
              potential_duplicate: false,
              trn:,
              access_your_teaching_qualifications_link: "https://aytq.com",
            },
          )
          allow(TRS::Client::V3::UpdateQTSRequest).to receive(:call).and_return(
            nil,
          )
        end

        it "marks the request as complete" do
          expect { perform }.to change(trs_trn_request, :complete?).to(true)
        end

        it "sets potential duplicate" do
          expect { perform }.to change(
            trs_trn_request,
            :potential_duplicate,
          ).to(false)
        end

        it "sends request to update QTS status on TRS" do
          perform

          expect(TRS::Client::V3::UpdateQTSRequest).to have_received(
            :call,
          ).with(application_form:, trn:, awarded_at: Time.zone.now)
        end

        it "awards QTS" do
          expect(AwardQTS).to receive(:call).with(
            application_form:,
            user: "TRS",
            trn:,
            access_your_teaching_qualifications_url: "https://aytq.com",
            awarded_at: Time.zone.now,
          )
          perform
        end

        it "doesn't queue another job" do
          expect { perform }.not_to have_enqueued_job(described_class)
        end
      end

      context "with a failure response for TRN allocation" do
        before do
          allow(TRS::Client::V3::CreateTRNRequest).to receive(:call).and_raise(
            Faraday::BadRequestError.new(StandardError.new),
          )
          allow(TRS::Client::V3::UpdateQTSRequest).to receive(:call).and_return(
            nil,
          )
        end

        it "leaves the request as initial" do
          expect { perform_rescue_exception }.not_to change(
            trs_trn_request,
            :state,
          )
        end

        it "leaves the potential duplicate" do
          expect { perform_rescue_exception }.not_to change(
            trs_trn_request,
            :potential_duplicate,
          )
        end

        it "doesn't send request to update QTS status on TRS" do
          perform_rescue_exception

          expect(TRS::Client::V3::UpdateQTSRequest).not_to have_received(:call)
        end

        it "doesn't award QTS" do
          expect(AwardQTS).not_to receive(:call)
          perform_rescue_exception
        end

        it "doesn't change the stage" do
          expect { perform_rescue_exception }.not_to change(
            application_form,
            :stage,
          )
        end

        it "raises the error" do
          expect { perform }.to raise_error(Faraday::BadRequestError)
        end
      end

      context "with a failure response for QTS award" do
        before do
          allow(TRS::Client::V3::CreateTRNRequest).to receive(:call).and_return(
            {
              potential_duplicate: false,
              trn:,
              access_your_teaching_qualifications_link: "https://aytq.com",
            },
          )
          allow(TRS::Client::V3::UpdateQTSRequest).to receive(:call).and_raise(
            Faraday::BadRequestError.new(StandardError.new),
          )
        end

        it "marks the request as pending" do
          expect { perform_rescue_exception }.to change(
            trs_trn_request,
            :pending?,
          ).to(true)
        end

        it "sets potential duplicate" do
          expect { perform_rescue_exception }.to change(
            trs_trn_request,
            :potential_duplicate,
          ).to(false)
        end

        it "doesn't award QTS" do
          expect(AwardQTS).not_to receive(:call)
          perform_rescue_exception
        end

        it "doesn't change the stage" do
          expect { perform_rescue_exception }.not_to change(
            application_form,
            :stage,
          )
        end

        it "raises the error" do
          expect { perform }.to raise_error(Faraday::BadRequestError)
        end
      end

      context "with a potential duplicate response" do
        before do
          allow(TRS::Client::V3::CreateTRNRequest).to receive(:call).and_return(
            { potential_duplicate: true },
          )
          allow(TRS::Client::V3::UpdateQTSRequest).to receive(:call).and_return(
            nil,
          )
        end

        it "marks the request as pending" do
          expect { perform }.to change(trs_trn_request, :pending?).to(true)
        end

        it "sets potential duplicate" do
          expect { perform }.to change(
            trs_trn_request,
            :potential_duplicate,
          ).to(true)
        end

        it "doesn't send request to update QTS status on TRS" do
          perform

          expect(TRS::Client::V3::UpdateQTSRequest).not_to have_received(:call)
        end

        it "doesn't award QTS" do
          expect(AwardQTS).not_to receive(:call)
          perform
        end

        it "changes the state" do
          expect { perform }.to change(application_form, :statuses).to(
            %w[potential_duplicate_in_dqt],
          )
        end

        it "queues another job" do
          expect { perform }.to have_enqueued_job(described_class).with(
            trs_trn_request,
          )
        end

        context "with trn included in the response" do
          before do
            allow(TRS::Client::V3::CreateTRNRequest).to receive(
              :call,
            ).and_return(
              {
                potential_duplicate: true,
                trn:,
                access_your_teaching_qualifications_link: "https://aytq.com",
              },
            )
            allow(TRS::Client::V3::UpdateQTSRequest).to receive(
              :call,
            ).and_return(nil)
          end

          it "marks the request as complete" do
            expect { perform }.to change(trs_trn_request, :complete?).to(true)
          end

          it "sets potential duplicate" do
            expect { perform }.to change(
              trs_trn_request,
              :potential_duplicate,
            ).to(false)
          end

          it "sends request to update QTS status on TRS" do
            perform

            expect(TRS::Client::V3::UpdateQTSRequest).to have_received(
              :call,
            ).with(application_form:, trn:, awarded_at: Time.zone.now)
          end

          it "awards QTS" do
            expect(AwardQTS).to receive(:call).with(
              application_form:,
              user: "TRS",
              trn:,
              access_your_teaching_qualifications_url: "https://aytq.com",
              awarded_at: Time.zone.now,
            )
            perform
          end

          it "doesn't queue another job" do
            expect { perform }.not_to have_enqueued_job(described_class)
          end
        end
      end
    end

    context "with a pending request" do
      let(:trs_trn_request) { create(:trs_trn_request, :pending) }

      context "with a successful response" do
        before do
          allow(TRS::Client::V3::ReadTRNRequest).to receive(:call).and_return(
            {
              potential_duplicate: false,
              trn:,
              access_your_teaching_qualifications_link: "https://aytq.com",
            },
          )
          allow(TRS::Client::V3::UpdateQTSRequest).to receive(:call).and_return(
            nil,
          )
        end

        it "marks the request as complete" do
          expect { perform }.to change(trs_trn_request, :complete?).to(true)
        end

        it "sets potential duplicate" do
          expect { perform }.to change(
            trs_trn_request,
            :potential_duplicate,
          ).to(false)
        end

        it "sends request to update QTS status on TRS" do
          perform

          expect(TRS::Client::V3::UpdateQTSRequest).to have_received(
            :call,
          ).with(application_form:, trn:, awarded_at: Time.zone.now)
        end

        it "awards QTS" do
          expect(AwardQTS).to receive(:call).with(
            application_form:,
            user: "TRS",
            trn:,
            access_your_teaching_qualifications_url: "https://aytq.com",
            awarded_at: Time.zone.now,
          )
          perform
        end

        it "doesn't queue another job" do
          expect { perform }.not_to have_enqueued_job(described_class)
        end
      end

      context "with a failure response for TRN allocation" do
        before do
          allow(TRS::Client::V3::ReadTRNRequest).to receive(:call).and_raise(
            Faraday::BadRequestError.new(StandardError.new),
          )
          allow(TRS::Client::V3::UpdateQTSRequest).to receive(:call).and_return(
            nil,
          )
        end

        it "leaves the request as pending" do
          expect { perform_rescue_exception }.not_to change(
            trs_trn_request,
            :state,
          )
        end

        it "leaves the potential duplicate" do
          expect { perform_rescue_exception }.not_to change(
            trs_trn_request,
            :potential_duplicate,
          )
        end

        it "doesn't send request to update QTS status on TRS" do
          perform_rescue_exception

          expect(TRS::Client::V3::UpdateQTSRequest).not_to have_received(:call)
        end

        it "doesn't award QTS" do
          expect(AwardQTS).not_to receive(:call)
          perform_rescue_exception
        end

        it "doesn't change the stage" do
          expect { perform_rescue_exception }.not_to change(
            application_form,
            :stage,
          )
        end

        it "raises the error" do
          expect { perform }.to raise_error(Faraday::BadRequestError)
        end
      end

      context "with a failure response for QTS award" do
        before do
          allow(TRS::Client::V3::ReadTRNRequest).to receive(:call).and_return(
            {
              potential_duplicate: false,
              trn:,
              access_your_teaching_qualifications_link: "https://aytq.com",
            },
          )
          allow(TRS::Client::V3::UpdateQTSRequest).to receive(:call).and_raise(
            Faraday::BadRequestError.new(StandardError.new),
          )
        end

        it "leaves the request as pending" do
          expect { perform_rescue_exception }.not_to change(
            trs_trn_request,
            :state,
          )
        end

        it "sets potential duplicate" do
          expect { perform_rescue_exception }.to change(
            trs_trn_request,
            :potential_duplicate,
          ).to(false)
        end

        it "doesn't award QTS" do
          expect(AwardQTS).not_to receive(:call)
          perform_rescue_exception
        end

        it "doesn't change the stage" do
          expect { perform_rescue_exception }.not_to change(
            application_form,
            :stage,
          )
        end

        it "raises the error" do
          expect { perform }.to raise_error(Faraday::BadRequestError)
        end
      end

      context "with a potential duplicate response" do
        before do
          allow(TRS::Client::V3::ReadTRNRequest).to receive(:call).and_return(
            { potential_duplicate: true },
          )
          allow(TRS::Client::V3::UpdateQTSRequest).to receive(:call).and_return(
            nil,
          )
        end

        it "leaves the request as pending" do
          expect { perform_rescue_exception }.not_to change(
            trs_trn_request,
            :state,
          )
        end

        it "sets potential duplicate" do
          expect { perform }.to change(
            trs_trn_request,
            :potential_duplicate,
          ).to(true)
        end

        it "doesn't send request to update QTS status on TRS" do
          perform

          expect(TRS::Client::V3::UpdateQTSRequest).not_to have_received(:call)
        end

        it "doesn't award QTS" do
          expect(AwardQTS).not_to receive(:call)
          perform
        end

        it "changes the state" do
          expect { perform }.to change(application_form, :statuses).to(
            %w[potential_duplicate_in_dqt],
          )
        end

        it "queues another job" do
          expect { perform }.to have_enqueued_job(described_class).with(
            trs_trn_request,
          )
        end

        context "with trn included in the response" do
          before do
            allow(TRS::Client::V3::ReadTRNRequest).to receive(:call).and_return(
              {
                potential_duplicate: true,
                trn:,
                access_your_teaching_qualifications_link: "https://aytq.com",
              },
            )
            allow(TRS::Client::V3::UpdateQTSRequest).to receive(
              :call,
            ).and_return(nil)
          end

          it "marks the request as complete" do
            expect { perform }.to change(trs_trn_request, :complete?).to(true)
          end

          it "sets potential duplicate" do
            expect { perform }.to change(
              trs_trn_request,
              :potential_duplicate,
            ).to(false)
          end

          it "sends request to update QTS status on TRS" do
            perform

            expect(TRS::Client::V3::UpdateQTSRequest).to have_received(
              :call,
            ).with(application_form:, trn:, awarded_at: Time.zone.now)
          end

          it "awards QTS" do
            expect(AwardQTS).to receive(:call).with(
              application_form:,
              user: "TRS",
              trn:,
              access_your_teaching_qualifications_url: "https://aytq.com",
              awarded_at: Time.zone.now,
            )
            perform
          end

          it "doesn't queue another job" do
            expect { perform }.not_to have_enqueued_job(described_class)
          end
        end
      end
    end

    context "with a complete request" do
      let(:trs_trn_request) { create(:trs_trn_request, :complete) }

      it "leaves the request as pending" do
        expect { perform_rescue_exception }.not_to change(
          trs_trn_request,
          :state,
        )
      end

      it "leaves the potential duplicate" do
        expect { perform_rescue_exception }.not_to change(
          trs_trn_request,
          :potential_duplicate,
        )
      end

      it "doesn't award QTS" do
        expect(AwardQTS).not_to receive(:call)
        perform
      end

      it "doesn't change the stage" do
        expect { perform }.not_to change(application_form, :stage)
      end

      it "doesn't queue another job" do
        expect { perform }.not_to have_enqueued_job(described_class)
      end
    end
  end
end
