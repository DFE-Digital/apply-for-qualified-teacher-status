# frozen_string_literal: true

require "rails_helper"

RSpec.describe HistoryController, type: :controller do
  describe "GET back" do
    let(:default) { "/fallback" }

    subject(:perform) { get :back, params: { origin:, default: } }

    context "with origin true" do
      let(:origin) { "true" }

      context "with a destination" do
        before do
          expect_any_instance_of(HistoryStack).to receive(
            :pop_to_origin,
          ).and_return("/origin")
        end

        it "redirects to the destination" do
          perform
          expect(response).to redirect_to("/origin")
        end
      end

      context "without a destination" do
        before do
          expect_any_instance_of(HistoryStack).to receive(
            :pop_to_origin,
          ).and_return(nil)
        end

        it "redirects to the default" do
          perform
          expect(response).to redirect_to("/fallback")
        end
      end
    end

    context "with origin false" do
      let(:origin) { "false" }

      context "with a destination" do
        before do
          expect_any_instance_of(HistoryStack).to receive(:pop_back).and_return(
            "/previous",
          )
        end

        it "redirects to the destination" do
          perform
          expect(response).to redirect_to("/previous")
        end
      end

      context "without a destination" do
        before do
          expect_any_instance_of(HistoryStack).to receive(:pop_back).and_return(
            nil,
          )
        end

        it "redirects to the default" do
          perform
          expect(response).to redirect_to("/fallback")
        end
      end
    end
  end
end
