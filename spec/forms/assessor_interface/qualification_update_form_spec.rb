# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::QualificationUpdateForm, type: :model do
  subject(:form) do
    described_class.new(
      qualification:,
      user:,
      certificate_date:,
      complete_date:,
      institution_name:,
      start_date:,
      title:,
      teaching_qualification_part_of_degree:,
    )
  end

  let(:qualification) { create(:qualification, :completed) }
  let(:user) { create(:staff) }

  let(:certificate_date) { { 1 => nil, 2 => nil, 3 => 1 } }
  let(:complete_date) { { 1 => nil, 2 => nil, 3 => 1 } }
  let(:start_date) { { 1 => nil, 2 => nil, 3 => 1 } }

  let(:title) { nil }
  let(:institution_name) { nil }

  let(:teaching_qualification_part_of_degree) { nil }

  describe "validations" do
    context "start date" do
      context "when after the existing complete date" do
        let(:qualification) do
          create(
            :qualification,
            :completed,
            complete_date: Date.parse("2000-01-01"),
          )
        end
        let(:start_date) { { 1 => 2001, 2 => 1, 3 => 1 } }

        it { is_expected.not_to be_valid }
      end

      context "when at the existing complete date" do
        let(:qualification) do
          create(
            :qualification,
            :completed,
            complete_date: Date.parse("2000-01-01"),
          )
        end
        let(:start_date) { { 1 => 2000, 2 => 1, 3 => 1 } }

        it { is_expected.not_to be_valid }
      end

      context "when before the existing complete date" do
        let(:qualification) do
          create(
            :qualification,
            :completed,
            complete_date: Date.parse("2000-01-01"),
          )
        end
        let(:start_date) { { 1 => 1997, 2 => 1, 3 => 1 } }

        it { is_expected.to be_valid }
      end

      context "when after the new complete date" do
        let(:start_date) { { 1 => 2001, 2 => 1, 3 => 1 } }
        let(:complete_date) { { 1 => 2000, 2 => 1, 3 => 1 } }

        it { is_expected.not_to be_valid }
      end

      context "when at the new complete date" do
        let(:start_date) { { 1 => 2000, 2 => 1, 3 => 1 } }
        let(:complete_date) { { 1 => 2000, 2 => 1, 3 => 1 } }

        it { is_expected.not_to be_valid }
      end

      context "when before the new complete date" do
        let(:start_date) { { 1 => 1997, 2 => 1, 3 => 1 } }
        let(:complete_date) { { 1 => 2000, 2 => 1, 3 => 1 } }

        it { is_expected.to be_valid }
      end
    end

    context "complete date" do
      context "when before the existing start date" do
        let(:qualification) do
          create(
            :qualification,
            :completed,
            start_date: Date.parse("2000-01-01"),
          )
        end
        let(:complete_date) { { 1 => 1999, 2 => 1, 3 => 1 } }

        it { is_expected.not_to be_valid }
      end

      context "when at the existing start date" do
        let(:qualification) do
          create(
            :qualification,
            :completed,
            start_date: Date.parse("2000-01-01"),
          )
        end
        let(:complete_date) { { 1 => 2000, 2 => 1, 3 => 1 } }

        it { is_expected.not_to be_valid }
      end

      context "when after the existing start date" do
        let(:qualification) do
          create(
            :qualification,
            :completed,
            start_date: Date.parse("2000-01-01"),
          )
        end
        let(:complete_date) { { 1 => 2001, 2 => 1, 3 => 1 } }

        it { is_expected.to be_valid }
      end

      context "when before the new start date" do
        let(:start_date) { { 1 => 2000, 2 => 1, 3 => 1 } }
        let(:complete_date) { { 1 => 1998, 2 => 1, 3 => 1 } }

        it { is_expected.not_to be_valid }
      end

      context "when at the new start date" do
        let(:start_date) { { 1 => 2000, 2 => 1, 3 => 1 } }
        let(:complete_date) { { 1 => 2000, 2 => 1, 3 => 1 } }

        it { is_expected.not_to be_valid }
      end

      context "when after the new start date" do
        let(:start_date) { { 1 => 2000, 2 => 1, 3 => 1 } }
        let(:complete_date) { { 1 => 2001, 2 => 1, 3 => 1 } }

        it { is_expected.to be_valid }
      end

      context "when before the existing certificate date" do
        let(:qualification) do
          create :qualification,
                 :completed,
                 start_date: Date.parse("1995-01-01"),
                 certificate_date: Date.parse("2000-01-01")
        end
        let(:complete_date) { { 1 => 1999, 2 => 1, 3 => 1 } }

        it { is_expected.to be_valid }
      end

      context "when at the existing certificate date" do
        let(:qualification) do
          create :qualification,
                 :completed,
                 start_date: Date.parse("1995-01-01"),
                 certificate_date: Date.parse("2000-01-01")
        end
        let(:complete_date) { { 1 => 2000, 2 => 1, 3 => 1 } }

        it { is_expected.to be_valid }
      end

      context "when after the existing certificate date" do
        let(:qualification) do
          create :qualification,
                 :completed,
                 start_date: Date.parse("1995-01-01"),
                 certificate_date: Date.parse("2000-01-01")
        end
        let(:complete_date) { { 1 => 2001, 2 => 1, 3 => 1 } }

        it { is_expected.not_to be_valid }
      end

      context "when before the new certificate date" do
        let(:qualification) do
          create :qualification,
                 :completed,
                 start_date: Date.parse("1995-01-01")
        end
        let(:complete_date) { { 1 => 1999, 2 => 1, 3 => 1 } }
        let(:certificate_date) { { 1 => 2000, 2 => 1, 3 => 1 } }

        it { is_expected.to be_valid }
      end

      context "when at the new certificate date" do
        let(:qualification) do
          create :qualification,
                 :completed,
                 start_date: Date.parse("1995-01-01")
        end
        let(:complete_date) { { 1 => 2000, 2 => 1, 3 => 1 } }
        let(:certificate_date) { { 1 => 2000, 2 => 1, 3 => 1 } }

        it { is_expected.to be_valid }
      end

      context "when after the new certificate date" do
        let(:qualification) do
          create :qualification,
                 :completed,
                 start_date: Date.parse("1995-01-01")
        end
        let(:complete_date) { { 1 => 2001, 2 => 1, 3 => 1 } }
        let(:certificate_date) { { 1 => 2000, 2 => 1, 3 => 1 } }

        it { is_expected.not_to be_valid }
      end
    end

    context "certificate date" do
      context "when before the existing complete date" do
        let(:qualification) do
          create(
            :qualification,
            :completed,
            complete_date: Date.parse("2000-01-01"),
          )
        end
        let(:certificate_date) { { 1 => 1999, 2 => 1, 3 => 1 } }

        it { is_expected.not_to be_valid }
      end

      context "when at the existing complete date" do
        let(:qualification) do
          create(
            :qualification,
            :completed,
            complete_date: Date.parse("2000-01-01"),
          )
        end
        let(:certificate_date) { { 1 => 2000, 2 => 1, 3 => 1 } }

        it { is_expected.to be_valid }
      end

      context "when after the existing complete date" do
        let(:qualification) do
          create(
            :qualification,
            :completed,
            complete_date: Date.parse("2000-01-01"),
          )
        end
        let(:certificate_date) { { 1 => 2001, 2 => 1, 3 => 1 } }

        it { is_expected.to be_valid }
      end

      context "when before the new complete date" do
        let(:qualification) do
          create :qualification,
                 :completed,
                 start_date: Date.parse("1995-01-01")
        end
        let(:complete_date) { { 1 => 2000, 2 => 1, 3 => 1 } }
        let(:certificate_date) { { 1 => 1999, 2 => 1, 3 => 1 } }

        it { is_expected.not_to be_valid }
      end

      context "when at the new complete date" do
        let(:qualification) do
          create :qualification,
                 :completed,
                 start_date: Date.parse("1995-01-01")
        end
        let(:complete_date) { { 1 => 2000, 2 => 1, 3 => 1 } }
        let(:certificate_date) { { 1 => 2000, 2 => 1, 3 => 1 } }

        it { is_expected.to be_valid }
      end

      context "when after the new complete date" do
        let(:qualification) do
          create :qualification,
                 :completed,
                 start_date: Date.parse("1995-01-01")
        end
        let(:complete_date) { { 1 => 2000, 2 => 1, 3 => 1 } }
        let(:certificate_date) { { 1 => 2001, 2 => 1, 3 => 1 } }

        it { is_expected.to be_valid }
      end
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    let(:certificate_date) { { 1 => 1999, 2 => 1, 3 => 1 } }
    let(:complete_date) { { 1 => 1999, 2 => 1, 3 => 1 } }
    let(:start_date) { { 1 => 1995, 2 => 1, 3 => 1 } }

    let(:title) { "New title" }
    let(:institution_name) { "New institution name" }

    let(:teaching_qualification_part_of_degree) do
      !qualification.application_form.teaching_qualification_part_of_degree
    end

    it "calls the update teaching qualification service" do
      expect(UpdateTeachingQualification).to receive(:call).with(
        qualification: qualification,
        user:,
        certificate_date:
          Date.new(
            certificate_date[1],
            certificate_date[2],
            certificate_date[3],
          ),
        complete_date:
          Date.new(complete_date[1], complete_date[2], complete_date[3]),
        institution_name:,
        start_date: Date.new(start_date[1], start_date[2], start_date[3]),
        title:,
        teaching_qualification_part_of_degree:,
      )
      expect(save).to be true
    end

    context "when UpdateTeachingQualification raises InvalidWorkHistoryDuration error" do
      before do
        allow(UpdateTeachingQualification).to receive(:call).and_raise(
          UpdateTeachingQualification::InvalidWorkHistoryDuration,
        )
      end

      it "returns false and adds an error to the form" do
        expect(save).to be(false)
        expect(form.errors.messages).to include(
          {
            certificate_date: [
              "The qualification awarded date cannot be changed because the " \
                "applicant will have less than 9 months of work experience",
            ],
          },
        )
      end
    end

    context "when the new values are the same as the existing ones" do
      let(:certificate_date) do
        {
          1 => qualification.certificate_date.year,
          2 => qualification.certificate_date.month,
          3 => qualification.certificate_date.day,
        }
      end
      let(:complete_date) do
        {
          1 => qualification.complete_date.year,
          2 => qualification.complete_date.month,
          3 => qualification.complete_date.day,
        }
      end
      let(:start_date) do
        {
          1 => qualification.start_date.year,
          2 => qualification.start_date.month,
          3 => qualification.start_date.day,
        }
      end

      let(:title) { qualification.title }
      let(:institution_name) { qualification.institution_name }

      let(:teaching_qualification_part_of_degree) do
        qualification.application_form.teaching_qualification_part_of_degree
      end

      it "calls the update teaching qualification service with nil values" do
        expect(UpdateTeachingQualification).to receive(:call).with(
          qualification: qualification,
          user:,
          certificate_date: nil,
          complete_date: nil,
          institution_name: nil,
          start_date: nil,
          title: nil,
          teaching_qualification_part_of_degree: nil,
        )
        expect(save).to be true
      end
    end
  end
end
