# frozen_string_literal: true

require "rails_helper"

module Filters
  RSpec.describe Name do
    subject { described_class.apply(scope:, params:) }

    context "the params include :name" do
      let(:params) { { name: "Dave" } }
      let(:scope) { ApplicationForm.all }

      context "first name match" do
        let!(:included) do
          create(
            :application_form,
            :with_personal_information,
            given_names: "Dave"
          )
        end
        let!(:filtered) do
          create(
            :application_form,
            :with_personal_information,
            given_names: "Maude",
            family_name: "Ling"
          )
        end

        it "returns a filtered scope" do
          expect(subject).to eq([included])
        end
      end

      context "first name partial match" do
        let!(:included) do
          create(
            :application_form,
            :with_personal_information,
            given_names: "Cornishpasty Dave"
          )
        end
        let!(:filtered) do
          create(
            :application_form,
            :with_personal_information,
            given_names: "Maude",
            family_name: "Ling"
          )
        end

        it "returns a filtered scope" do
          expect(subject).to eq([included])
        end
      end

      context "family name match" do
        let!(:included) do
          create(
            :application_form,
            :with_personal_information,
            family_name: "Dave"
          )
        end
        let!(:filtered) do
          create(
            :application_form,
            :with_personal_information,
            given_names: "Maude",
            family_name: "Ling"
          )
        end

        it "returns a filtered scope" do
          expect(subject).to eq([included])
        end
      end

      context "family name partial match" do
        let!(:included) do
          create(
            :application_form,
            :with_personal_information,
            family_name: "Davethegangster"
          )
        end
        let!(:filtered) do
          create(
            :application_form,
            :with_personal_information,
            given_names: "Maude",
            family_name: "Ling"
          )
        end

        it "returns a filtered scope" do
          expect(subject).to eq([included])
        end
      end

      context "match with different case" do
        let(:params) { { name: "daVe" } }

        let!(:included) do
          create(
            :application_form,
            :with_personal_information,
            family_name: "Dave"
          )
        end

        it "returns a filtered scope" do
          expect(subject).to eq([included])
        end
      end
    end

    context "the params don't include :name" do
      let(:params) { {} }
      let(:scope) { double }

      it "returns the original scope" do
        expect(subject).to eq(scope)
      end
    end
  end
end
