# frozen_string_literal: true

require "rails_helper"

RSpec.describe FindOrCreateTeacherFromGovOne do
  subject(:call) do
    described_class.call(email:, gov_one_id:, eligibility_check:)
  end

  let(:email) { "test@example.com" }
  let(:gov_one_id) { "123456789" }
  let(:eligibility_check) { nil }

  it "creates a teacher record" do
    expect { call }.to change(Teacher, :count).by(1)
  end

  it "ensures the teacher record has the email and gov_one_id provided" do
    teacher = call

    expect(teacher).to have_attributes(email:, gov_one_id:, gov_one_email: email)
  end

  context "when eligibility_check_id is provided" do
    context "with it being eligible" do
      let(:eligibility_check) { create :eligibility_check, :eligible }

      it "generates an application form for the teacher record" do
        teacher = call

        expect(teacher.application_forms).not_to be_empty
        expect(teacher.application_forms.first.region.country.code).to eq(
          eligibility_check.country_code,
        )
      end
    end

    context "with it not being eligible" do
      let(:eligibility_check) { create :eligibility_check, :ineligible }

      it "does not generate an application form for the teacher record" do
        teacher = call

        expect(teacher.application_forms).to be_empty
      end
    end
  end

  context "when a teacher record with the same email and gov_one_id exists" do
    let!(:existing_teacher) { create :teacher, email:, gov_one_id: }

    it "does not generate a new teacher record" do
      expect { call }.not_to change(Teacher, :count)
    end

    it "returns the existing teacher record" do
      expect(call).to eq(existing_teacher)
    end

    it "sets the gov_one_email on the teacher record" do
      call

      expect(existing_teacher.reload.gov_one_email).to eq(email)
    end
  end

  context "when a teacher record with the same email exists without a gov_one_id" do
    let!(:existing_teacher) { create :teacher, email: }

    it "does not generate a new teacher record" do
      expect { call }.not_to change(Teacher, :count)
    end

    it "returns the existing teacher record" do
      expect(call).to eq(existing_teacher)
    end

    it "sets the gov_one_id on the existing teacher record" do
      call

      expect(existing_teacher.reload.gov_one_id).to eq(gov_one_id)
    end


    it "sets the gov_one_email on the existing teacher record" do
      call

      expect(existing_teacher.reload.gov_one_email).to eq(email)
    end
  end

  context "when a teacher record exists with gov_one_id but a different email" do
    let!(:existing_teacher) do
      create :teacher, email: "differentemail@example.com", gov_one_id:
    end

    it "does not generate a new teacher record" do
      expect { call }.not_to change(Teacher, :count)
    end

    it "returns the teacher record matching the gov one id" do
      expect(call).to eq(existing_teacher)
    end

    it "sets the gov_one_email on the existing teacher record" do
      call

      expect(existing_teacher.reload.gov_one_email).to eq(email)
    end
  end

  context "when two teacher records exist, one matching gov_one_id and another the email" do
    let!(:existing_teacher_matching_id) do
      create :teacher, email: "differentemail@example.com", gov_one_id:
    end

    before { create :teacher, email:, gov_one_id: "other-id" }

    it "does not generate a new teacher record" do
      expect { call }.not_to change(Teacher, :count)
    end

    it "returns the teacher record matching the gov one id as priority" do
      expect(call).to eq(existing_teacher_matching_id)
    end

    it "sets the gov_one_email on teacher record matching the gov one id as priority" do
      call

      expect(existing_teacher_matching_id.reload.gov_one_email).to eq(email)
    end
  end
end
