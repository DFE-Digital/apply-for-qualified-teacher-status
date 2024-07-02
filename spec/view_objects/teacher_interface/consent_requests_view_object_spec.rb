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
                  link: [
                    :teacher_interface,
                    :application_form,
                    consent_request.signed_consent_document,
                  ],
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
end
