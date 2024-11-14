# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateTRSTRNRequestJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(dqt_trn_request) }

    let(:application_form) { dqt_trn_request.application_form }
    let(:teacher) { application_form.teacher }

    # rubocop:disable Lint/SuppressedException
    let(:perform_rescue_exception) do
      perform
    rescue StandardError
    end
    # rubocop:enable Lint/SuppressedException

    context "with an initial request" do
      let(:dqt_trn_request) { create(:dqt_trn_request, :initial) }

      context "with a successful response" do
        before do
          allow(TRS::Client::CreateTRNRequest).to receive(:call).and_return(
            {
              potential_duplicate: false,
              trn: "abcdef",
              access_your_teaching_qualifications_link: "https://aytq.com",
            },
          )
        end

        it "marks the request as complete" do
          expect { perform }.to change(dqt_trn_request, :complete?).to(true)
        end

        it "sets potential duplicate" do
          expect { perform }.to change(
            dqt_trn_request,
            :potential_duplicate,
          ).to(false)
        end

        it "awards QTS" do
          expect(AwardQTS).to receive(:call).with(
            application_form:,
            user: "DQT",
            trn: "abcdef",
            access_your_teaching_qualifications_url: "https://aytq.com",
          )
          perform
        end

        it "doesn't queue another job" do
          expect { perform }.not_to have_enqueued_job(described_class)
        end
      end

      context "with a failure response" do
        before do
          allow(TRS::Client::CreateTRNRequest).to receive(:call).and_raise(
            Faraday::BadRequestError.new(StandardError.new),
          )
        end

        it "leaves the request as initial" do
          expect { perform_rescue_exception }.not_to change(
            dqt_trn_request,
            :state,
          )
        end

        it "leaves the potential duplicate" do
          expect { perform_rescue_exception }.not_to change(
            dqt_trn_request,
            :potential_duplicate,
          )
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
          allow(TRS::Client::CreateTRNRequest).to receive(:call).and_return(
            { potential_duplicate: true },
          )
        end

        it "marks the request as pending" do
          expect { perform }.to change(dqt_trn_request, :pending?).to(true)
        end

        it "sets potential duplicate" do
          expect { perform }.to change(
            dqt_trn_request,
            :potential_duplicate,
          ).to(true)
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
            dqt_trn_request,
          )
        end
      end
    end

    context "with a pending request" do
      let(:dqt_trn_request) { create(:dqt_trn_request, :pending) }

      context "with a successful response" do
        before do
          allow(TRS::Client::ReadTRNRequest).to receive(:call).and_return(
            {
              potential_duplicate: false,
              trn: "abcdef",
              access_your_teaching_qualifications_link: "https://aytq.com",
            },
          )
        end

        it "marks the request as complete" do
          expect { perform }.to change(dqt_trn_request, :complete?).to(true)
        end

        it "sets potential duplicate" do
          expect { perform }.to change(
            dqt_trn_request,
            :potential_duplicate,
          ).to(false)
        end

        it "awards QTS" do
          expect(AwardQTS).to receive(:call).with(
            application_form:,
            user: "DQT",
            trn: "abcdef",
            access_your_teaching_qualifications_url: "https://aytq.com",
          )
          perform
        end

        it "doesn't queue another job" do
          expect { perform }.not_to have_enqueued_job(described_class)
        end
      end

      context "with a failure response" do
        before do
          allow(TRS::Client::ReadTRNRequest).to receive(:call).and_raise(
            Faraday::BadRequestError.new(StandardError.new),
          )
        end

        it "leaves the request as pending" do
          expect { perform_rescue_exception }.not_to change(
            dqt_trn_request,
            :state,
          )
        end

        it "leaves the potential duplicate" do
          expect { perform_rescue_exception }.not_to change(
            dqt_trn_request,
            :potential_duplicate,
          )
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
          allow(TRS::Client::ReadTRNRequest).to receive(:call).and_return(
            { potential_duplicate: true },
          )
        end

        it "leaves the request as pending" do
          expect { perform_rescue_exception }.not_to change(
            dqt_trn_request,
            :state,
          )
        end

        it "sets potential duplicate" do
          expect { perform }.to change(
            dqt_trn_request,
            :potential_duplicate,
          ).to(true)
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
            dqt_trn_request,
          )
        end
      end
    end

    context "with a complete request" do
      let(:dqt_trn_request) { create(:dqt_trn_request, :complete) }

      it "leaves the request as pending" do
        expect { perform_rescue_exception }.not_to change(
          dqt_trn_request,
          :state,
        )
      end

      it "leaves the potential duplicate" do
        expect { perform_rescue_exception }.not_to change(
          dqt_trn_request,
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
