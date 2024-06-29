require "rails_helper"

RSpec.describe TeacherInterface::QualificationForm, type: :model do
  subject(:form) do
    described_class.new(
      qualification:,
      title:,
      institution_name:,
      institution_country_location:,
      start_date:,
      complete_date:,
      certificate_date:,
      teaching_confirmation:,
    )
  end

  let(:application_form) do
    create(
      :application_form,
      region: create(:region, :in_country, country_code: "FR"),
    )
  end
  let(:qualification) { build(:qualification, application_form:) }

  describe "validations" do
    let(:title) { "" }
    let(:institution_name) { "" }
    let(:institution_country_location) { "" }
    let(:start_date) { "" }
    let(:complete_date) { "" }
    let(:certificate_date) { "" }
    let(:teaching_confirmation) { "" }

    it { is_expected.to validate_presence_of(:qualification) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:institution_name) }
    it { is_expected.to validate_presence_of(:institution_country_location) }

    it do
      expect(subject).to validate_inclusion_of(
        :institution_country_location,
      ).in_array(%w[country:FR])
    end

    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:complete_date) }
    it { is_expected.to validate_presence_of(:certificate_date) }
    it { is_expected.to validate_presence_of(:teaching_confirmation) }

    context "with a university degree" do
      # create the teaching qualification first
      before { create(:qualification, application_form:) }

      it do
        expect(subject).not_to validate_inclusion_of(
          :institution_country_location,
        ).in_array(%w[country:FR])
      end

      it { is_expected.not_to validate_presence_of(:teaching_confirmation) }
    end

    context "with invalid dates" do
      let(:start_date) { { 1 => 2020, 2 => 1, 3 => 1 } }
      let(:complete_date) { { 1 => 2019, 2 => 1, 3 => 1 } }

      it { is_expected.not_to be_valid }
    end

    context "with invalid dates" do
      let(:complete_date) { { 1 => 2020, 2 => 1, 3 => 1 } }
      let(:certificate_date) { { 1 => 2019, 2 => 1, 3 => 1 } }

      it { is_expected.not_to be_valid }
    end
  end

  context "with a country code" do
    subject(:institution_country_location) do
      described_class.new(
        institution_country_code: "FR",
      ).institution_country_location
    end

    it { is_expected.to eq("country:FR") }
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    let(:title) { "Title" }
    let(:institution_name) { "Institution name" }
    let(:institution_country_location) { "country:FR" }
    let(:start_date) { { 1 => 2020, 2 => 1, 3 => 1 } }
    let(:complete_date) { { 1 => 2022, 2 => 1, 3 => 1 } }
    let(:certificate_date) { { 1 => 2022, 2 => 6, 3 => 1 } }
    let(:teaching_confirmation) { "true" }

    it "saves the qualification" do
      expect(save).to be true
      expect(qualification.title).to eq("Title")
      expect(qualification.institution_name).to eq("Institution name")
      expect(qualification.institution_country_code).to eq("FR")
      expect(qualification.start_date).to eq(Date.new(2020, 1, 1))
      expect(qualification.complete_date).to eq(Date.new(2022, 1, 1))
      expect(qualification.certificate_date).to eq(Date.new(2022, 6, 1))
    end

    it "doesn't show the duration banner" do
      expect(save).to be true
      expect(
        application_form.qualification_changed_work_history_duration,
      ).to be false
    end

    context "without validation, with invalid date values" do
      subject(:save) { form.save(validate: false) }

      let(:start_date) { { 1 => 2222, 2 => 22, 3 => 1 } }
      let(:complete_date) { { 1 => 3333, 2 => 99, 3 => 1 } }
      let(:certificate_date) { { 1 => 99, 2 => "JUNE", 3 => 1 } }

      it "applies valid date values" do
        expect(save).to be true
        expect(qualification.start_date).to eq(
          Date.new(Time.zone.now.year, 1, 1),
        )
        expect(qualification.complete_date).to eq(
          Date.new(Time.zone.now.year, 1, 1),
        )
        expect(qualification.certificate_date).to eq(
          Date.new(Time.zone.now.year, 1, 1),
        )
      end
    end

    context "with existing work history prior to certificate date" do
      before do
        create(
          :work_history,
          application_form:,
          start_date: Date.new(2020, 1, 1),
          end_date: Date.new(2021, 1, 1),
          hours_per_week: 40,
        )
      end

      it "shows the duration banner" do
        expect(save).to be true
        expect(
          application_form.qualification_changed_work_history_duration,
        ).to be true
      end
    end

    context "with existing work history crossing the certificate date" do
      before do
        create(
          :work_history,
          application_form:,
          start_date: Date.new(2020, 1, 1),
          end_date: Date.new(2023, 9, 1),
          hours_per_week: 40,
        )
      end

      it "shows the duration banner" do
        expect(save).to be true
        expect(
          application_form.qualification_changed_work_history_duration,
        ).to be true
      end
    end

    context "with existing work history after the certificate date" do
      before do
        create(
          :work_history,
          application_form:,
          start_date: Date.new(2021, 1, 1),
          end_date: Date.new(2026, 1, 1),
          hours_per_week: 40,
        )
      end

      it "doesn't show the duration banner" do
        expect(save).to be true
        expect(
          application_form.qualification_changed_work_history_duration,
        ).to be false
      end
    end
  end
end
