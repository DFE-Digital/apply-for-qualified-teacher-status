# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateDQTTRNRequestJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(dqt_trn_request) }

    let(:application_form) { dqt_trn_request.application_form }
    let(:teacher) { application_form.teacher }

    let(:perform_rescue_exception) do
      perform
    rescue StandardError
    end

    context "with an initial request" do
      let(:dqt_trn_request) { create(:dqt_trn_request, :initial) }

      context "with a successful response" do
        before do
          expect(DQT::Client::CreateTRNRequest).to receive(:call).and_return(
            { trn: "abcdef" },
          )
        end

        it "marks the request as complete" do
          perform
          expect(dqt_trn_request.reload.state).to eq("complete")
        end

        it "awards QTS" do
          expect(AwardQTS).to receive(:call).with(
            application_form:,
            user: "DQT",
            trn: "abcdef",
          )
          perform
        end

        it "doesn't raise an error" do
          expect { perform }.to_not raise_error
        end
      end

      context "with a failure response" do
        before do
          expect(DQT::Client::CreateTRNRequest).to receive(:call).and_raise(
            Faraday::BadRequestError.new(StandardError.new),
          )
        end

        it "leaves the request as initial" do
          perform_rescue_exception
          expect(dqt_trn_request.reload.state).to eq("initial")
        end

        it "doesn't award QTS" do
          expect(AwardQTS).to_not receive(:call)
          perform_rescue_exception
        end

        it "raises the error" do
          expect { perform }.to raise_error(Faraday::BadRequestError)
        end
      end

      context "with a pending response" do
        before do
          expect(DQT::Client::CreateTRNRequest).to receive(:call).and_return({})
        end

        it "marks the request as pending" do
          perform_rescue_exception
          expect(dqt_trn_request.reload.state).to eq("pending")
        end

        it "doesn't award QTS" do
          expect(AwardQTS).to_not receive(:call)
          perform_rescue_exception
        end

        it "raises a still pending error" do
          expect { perform }.to raise_error(
            UpdateDQTTRNRequestJob::StillPending,
          )
        end
      end
    end

    context "with a pending request" do
      let(:dqt_trn_request) { create(:dqt_trn_request, :pending) }

      context "with a successful response" do
        context "with a TRN" do
          before do
            expect(DQT::Client::ReadTRNRequest).to receive(:call).and_return(
              { trn: "abcdef", potentialDuplicate: false },
            )
          end

          it "marks the request as complete" do
            perform
            expect(dqt_trn_request.reload.state).to eq("complete")
          end

          it "awards QTS" do
            expect(AwardQTS).to receive(:call).with(
              application_form:,
              user: "DQT",
              trn: "abcdef",
            )
            perform
          end

          it "doesn't raise an error" do
            expect { perform }.to_not raise_error
          end
        end

        context "where a potential duplicate is found" do
          before do
            expect(DQT::Client::ReadTRNRequest).to receive(:call).and_return(
              { trn: nil, potential_duplicate: true },
            )
          end

          it "leaves the request pending" do
            perform_rescue_exception
            expect(dqt_trn_request.reload.state).to eq("pending")
          end

          it "it does not award QTS" do
            expect(AwardQTS).not_to receive(:call)
            perform_rescue_exception
          end

          it "raises a still pending error" do
            expect { perform }.to raise_error(
              UpdateDQTTRNRequestJob::StillPending,
            )
          end

          it "sets the application form to potential_duplicate_in_dqt" do
            expect { perform_rescue_exception }.to change {
              application_form.potential_duplicate_in_dqt?
            }.from(false).to(true)
          end
        end
      end

      context "with a failure response" do
        before do
          expect(DQT::Client::ReadTRNRequest).to receive(:call).and_raise(
            Faraday::BadRequestError.new(StandardError.new),
          )
        end

        it "leaves the request as pending" do
          perform_rescue_exception
          expect(dqt_trn_request.reload.state).to eq("pending")
        end

        it "doesn't award QTS" do
          expect(AwardQTS).to_not receive(:call)
          perform_rescue_exception
        end

        it "raises the error" do
          expect { perform }.to raise_error(Faraday::BadRequestError)
        end
      end

      context "with a pending response" do
        before do
          expect(DQT::Client::ReadTRNRequest).to receive(:call).and_return({})
        end

        it "leaves the request as pending" do
          perform_rescue_exception
          expect(dqt_trn_request.reload.state).to eq("pending")
        end

        it "doesn't award QTS" do
          expect(AwardQTS).to_not receive(:call)
          perform_rescue_exception
        end

        it "raises a still pending error" do
          expect { perform }.to raise_error(
            UpdateDQTTRNRequestJob::StillPending,
          )
        end
      end
    end

    context "with a complete request" do
      let(:dqt_trn_request) { create(:dqt_trn_request, :complete) }

      it "leaves the request as complete" do
        perform
        expect(dqt_trn_request.reload.state).to eq("complete")
      end

      it "doesn't award QTS" do
        expect(AwardQTS).to_not receive(:call)
        perform
      end

      it "doesn't raise an error" do
        expect { perform }.to_not raise_error
      end
    end
  end
end
