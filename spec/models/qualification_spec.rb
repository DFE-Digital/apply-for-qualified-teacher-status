# == Schema Information
#
# Table name: qualifications
#
#  id                        :bigint           not null, primary key
#  certificate_date          :date
#  complete_date             :date
#  institution_country_code  :text             default(""), not null
#  institution_name          :text             default(""), not null
#  part_of_university_degree :boolean
#  start_date                :date
#  title                     :text             default(""), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  application_form_id       :bigint           not null
#
# Indexes
#
#  index_qualifications_on_application_form_id  (application_form_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
require "rails_helper"

RSpec.describe Qualification, type: :model do
  subject(:qualification) { create(:qualification) }

  it_behaves_like "a documentable"

  describe "validations" do
    it { is_expected.to be_valid }
  end

  describe "#is_teaching_qualification?" do
    subject(:is_teaching_qualification?) do
      qualification.is_teaching_qualification?
    end

    before { qualification.save! }

    it { is_expected.to be true }

    context "with a second qualification" do
      subject(:is_teaching_qualification?) do
        second_qualification.is_teaching_qualification?
      end

      let(:second_qualification) do
        create(:qualification, application_form: qualification.application_form)
      end

      it { is_expected.to be false }
    end
  end

  describe "#is_university_degree?" do
    subject(:is_university_degree?) { qualification.is_university_degree? }

    before { qualification.save! }

    it { is_expected.to be false }

    context "with a second qualification" do
      subject(:is_university_degree?) do
        second_qualification.is_university_degree?
      end

      let(:second_qualification) do
        create(:qualification, application_form: qualification.application_form)
      end

      it { is_expected.to be true }
    end
  end

  describe "#can_delete?" do
    subject(:can_delete?) { qualification.can_delete? }

    it { is_expected.to be false }

    context "is a university degree" do
      subject(:can_delete?) { second_qualification.reload.can_delete? }

      let(:second_qualification) do
        create(:qualification, application_form: qualification.application_form)
      end

      context "and qualification part of degree" do
        before { qualification.update!(part_of_university_degree: true) }

        it { is_expected.to be true }
      end

      context "and qualification not part of degree" do
        before { qualification.update!(part_of_university_degree: false) }

        it { is_expected.to be false }

        context "and more than 2 degree qualifications" do
          before do
            create(
              :qualification,
              application_form: qualification.application_form,
            )
          end

          it { is_expected.to be true }
        end
      end
    end
  end

  describe "#complete?" do
    subject(:complete?) { qualification.complete? }

    it { is_expected.to be false }

    context "with a partially complete qualification" do
      before { qualification.update!(title: "Title") }

      it { is_expected.to be false }
    end

    context "with a complete qualification" do
      before do
        qualification.update!(
          title: "Title",
          institution_name: "Institution name",
          institution_country_code: "FR",
          start_date: Date.new(2020, 1, 1),
          complete_date: Date.new(2021, 1, 1),
          certificate_date: Date.new(2021, 1, 1),
          part_of_university_degree: true,
        )

        create(:upload, document: qualification.certificate_document)
        create(:upload, document: qualification.transcript_document)
      end

      it { is_expected.to be true }
    end
  end
end
