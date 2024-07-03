# frozen_string_literal: true

require "rails_helper"

RSpec.describe HistoryStack do
  subject(:history_stack) { described_class.new(session:) }

  describe "#push_self" do
    subject(:push_self) do
      history_stack.push_self(request, origin:, check:, reset:)
    end

    let(:request) { OpenStruct.new(fullpath: "/path?page=1") }
    let(:check) { false }

    context "with an empty session" do
      let(:session) { {} }
      let(:reset) { false }

      context "when origin" do
        let(:origin) { true }

        it "stores the stack in the session" do
          expect { push_self }.to change { session }.to(
            {
              history_stack: [
                { origin: true, check: false, path: "/path?page=1" },
              ],
            },
          )
        end

        it "doesn't store it twice" do
          expect { 2.times { push_self } }.to change { session }.to(
            {
              history_stack: [
                { origin: true, check: false, path: "/path?page=1" },
              ],
            },
          )
        end
      end

      context "when not origin" do
        let(:origin) { false }

        it "stores the stack in the session" do
          expect { push_self }.to change { session }.to(
            {
              history_stack: [
                { origin: false, check: false, path: "/path?page=1" },
              ],
            },
          )
        end
      end
    end

    context "with an existing session" do
      let(:session) do
        { history_stack: [{ path: "/origin", check: false, origin: true }] }
      end
      let(:origin) { false }

      context "when resetting" do
        let(:reset) { true }

        it "stores the stack in the session" do
          expect { push_self }.to change { session }.to(
            {
              history_stack: [
                { origin: false, check: false, path: "/path?page=1" },
              ],
            },
          )
        end
      end

      context "when not resetting" do
        let(:reset) { false }

        it "stores the stack in the session" do
          expect { push_self }.to change { session }.to(
            {
              history_stack: [
                { origin: true, check: false, path: "/origin" },
                { origin: false, check: false, path: "/path?page=1" },
              ],
            },
          )
        end
      end
    end
  end

  describe "#pop_back" do
    subject(:pop_back) { history_stack.pop_back }

    context "with an empty session" do
      let(:session) { {} }

      it { is_expected.to be_nil }
    end

    context "with an existing session" do
      let(:session) do
        {
          history_stack: [
            { path: "/origin", origin: true },
            { path: "/page", origin: false },
          ],
        }
      end

      it { is_expected.to eq("/origin") }

      it "stores the stack in the session" do
        expect { pop_back }.to change { session }.to({ history_stack: [] })
      end
    end
  end

  describe "#pop_to_origin" do
    subject(:pop_to_origin) { history_stack.pop_to_origin }

    context "with an empty session" do
      let(:session) { {} }

      it { is_expected.to be_nil }
    end

    context "with an existing session" do
      let(:session) do
        {
          history_stack: [
            { path: "/origin", origin: true },
            { path: "/page1", origin: false },
            { path: "/page2", origin: false },
          ],
        }
      end

      it { is_expected.to eq("/origin") }

      it "stores the stack in the session" do
        expect { pop_to_origin }.to change { session }.to({ history_stack: [] })
      end
    end
  end

  describe "#replace_self" do
    subject(:replace_self) do
      history_stack.replace_self(path:, origin:, check:)
    end

    let(:path) { "/path?page=1" }
    let(:check) { false }

    context "with an empty session" do
      let(:session) { {} }

      context "when origin" do
        let(:origin) { true }

        it "stores the stack in the session" do
          expect { replace_self }.to change { session }.to(
            {
              history_stack: [
                { origin: true, check: false, path: "/path?page=1" },
              ],
            },
          )
        end

        it "doesn't store it twice" do
          expect { 2.times { replace_self } }.to change { session }.to(
            {
              history_stack: [
                { origin: true, check: false, path: "/path?page=1" },
              ],
            },
          )
        end
      end

      context "when not origin" do
        let(:origin) { false }

        it "stores the stack in the session" do
          expect { replace_self }.to change { session }.to(
            {
              history_stack: [
                { origin: false, check: false, path: "/path?page=1" },
              ],
            },
          )
        end
      end
    end

    context "with an existing session" do
      let(:session) do
        { history_stack: [{ path: "/origin", check: false, origin: true }] }
      end
      let(:origin) { false }

      it "stores the stack in the session" do
        expect { replace_self }.to change { session }.to(
          {
            history_stack: [
              { origin: false, check: false, path: "/path?page=1" },
            ],
          },
        )
      end
    end
  end
end
