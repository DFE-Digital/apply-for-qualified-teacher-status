# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::ConsentRequestsViewObject do
  subject(:view_object) { described_class.new(application_form:) }

  let(:application_form) do
    create(:application_form, :verification_stage, :with_assessment)
  end

  describe "#task_list_sections" do
    subject(:task_list_sections) { view_object.task_list_sections }

    it { is_expected.to be_empty }

    context "with a consent request" do
      let!(:consent_request) do
        create(
          :consent_request,
          :requested,
          assessment: application_form.assessment,
          qualification:
            create(
              :qualification,
              application_form:,
              title: "BSc Maths",
              institution_name: "University of Maths",
            ),
        )
      end

      it do
        expect(subject).to eq(
          [
            {
              title: "BSc Maths (University of Maths)",
              items: [
                {
                  name: "Download University of Maths consent document",
                  link: [
                    :download,
                    :teacher_interface,
                    :application_form,
                    consent_request,
                  ],
                  status: :not_started,
                },
                {
                  name: "Upload University of Maths consent document",
                  link: nil,
                  status: :cannot_start,
                },
              ],
            },
          ],
        )
      end

      context "when the unsigned consent document is downloaded" do
        before { consent_request.update!(unsigned_document_downloaded: true) }

        it do
          expect(subject).to eq(
            [
              {
                title: "BSc Maths (University of Maths)",
                items: [
                  {
                    name: "Download University of Maths consent document",
                    link: [
                      :download,
                      :teacher_interface,
                      :application_form,
                      consent_request,
                    ],
                    status: :completed,
                  },
                  {
                    name: "Upload University of Maths consent document",
                    link: [
                      :teacher_interface,
                      :application_form,
                      consent_request.signed_consent_document,
                    ],
                    status: :not_started,
                  },
                ],
              },
            ],
          )
        end

        context "when the signed consent document is uploaded" do
          before do
            create(
              :upload,
              :clean,
              document: consent_request.signed_consent_document,
            )
          end

          it do
            expect(subject).to eq(
              [
                {
                  title: "BSc Maths (University of Maths)",
                  items: [
                    {
                      name: "Download University of Maths consent document",
                      link: [
                        :download,
                        :teacher_interface,
                        :application_form,
                        consent_request,
                      ],
                      status: :completed,
                    },
                    {
                      name: "Upload University of Maths consent document",
                      link: [
                        :teacher_interface,
                        :application_form,
                        consent_request.signed_consent_document,
                      ],
                      status: :completed,
                    },
                  ],
                },
              ],
            )
          end
        end
      end
    end
  end

  describe "#can_submit?" do
    subject(:can_submit?) { view_object.can_submit? }

    context "with incomplete consent requests" do
      before do
        create(
          :consent_request,
          :requested,
          assessment: application_form.assessment,
        )
      end

      it { is_expected.to be false }
    end

    context "with complete consent requests" do
      before do
        create(
          :consent_request,
          :requested,
          :with_signed_upload,
          assessment: application_form.assessment,
          unsigned_document_downloaded: true,
        )
      end

      it { is_expected.to be true }
    end
  end

  describe "#check_your_answers_task_group" do
    subject(:check_your_answers_task_group) do
      view_object.check_your_answers_task_group
    end

    context "when items are incomplete" do
      before do
        create(
          :consent_request,
          :requested,
          assessment: application_form.assessment,
        )
      end

      it "disables check your answers in task list group" do
        expect(check_your_answers_task_group[:heading]).to eq(
          "Check your answers",
        )
        expect(check_your_answers_task_group[:items].first[:status]).to eq(
          "cannot_start",
        )
        expect(check_your_answers_task_group[:items].first[:href]).to be_nil
      end
    end

    context "when items are complete" do
      before do
        create(
          :consent_request,
          :requested,
          :with_signed_upload,
          assessment: application_form.assessment,
          unsigned_document_downloaded: true,
        )
      end

      it "enables check your answers in task list group" do
        expect(check_your_answers_task_group[:heading]).to eq(
          "Check your answers",
        )
        expect(check_your_answers_task_group[:items].first[:status]).to eq(
          "not_started",
        )
        expect(check_your_answers_task_group[:items].first[:href]).to be_present
      end
    end

    context "when there are two consent requests" do
      context "when one is incomplete and the other is complete" do
        before do
          create(
            :consent_request,
            :requested,
            assessment: application_form.assessment,
          )
          create(
            :consent_request,
            :requested,
            :with_signed_upload,
            assessment: application_form.assessment,
            unsigned_document_downloaded: true,
          )
        end

        it "disables check your answers in task list group" do
          expect(check_your_answers_task_group[:heading]).to eq(
            "Check your answers",
          )
          expect(check_your_answers_task_group[:items].first[:status]).to eq(
            "cannot_start",
          )
          expect(check_your_answers_task_group[:items].first[:href]).to be_nil
        end
      end

      context "when both are complete" do
        before do
          create(
            :consent_request,
            :requested,
            :with_signed_upload,
            assessment: application_form.assessment,
            unsigned_document_downloaded: true,
          )
          create(
            :consent_request,
            :requested,
            :with_signed_upload,
            assessment: application_form.assessment,
            unsigned_document_downloaded: true,
          )
        end

        it "enables check your answers in task list group" do
          expect(check_your_answers_task_group[:heading]).to eq(
            "Check your answers",
          )
          expect(check_your_answers_task_group[:items].first[:status]).to eq(
            "not_started",
          )
          expect(
            check_your_answers_task_group[:items].first[:href],
          ).to be_present
        end
      end
    end
  end
end
