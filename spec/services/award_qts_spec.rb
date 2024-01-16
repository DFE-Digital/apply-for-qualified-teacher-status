# frozen_string_literal: true

require "rails_helper"

RSpec.describe AwardQTS do
  let(:teacher) { create(:teacher) }
  let(:user) { create(:staff, :confirmed) }
  let(:trn) { "abcdef" }
  let(:access_your_teaching_qualifications_url) { "https://aytq.com" }

  subject(:call) do
    described_class.call(
      application_form:,
      user:,
      trn:,
      access_your_teaching_qualifications_url:,
    )
  end

  context "with a submitted application form" do
    let(:application_form) { create(:application_form, :submitted, teacher:) }

    it "raises an error" do
      expect { call }.to raise_error(AwardQTS::InvalidState)
    end
  end

  context "with an awarded pending checks application form" do
    let(:application_form) do
      create(:application_form, :awarded_pending_checks, teacher:)
    end

    before { create(:dqt_trn_request, application_form:) }

    it "sets the TRN" do
      expect { call }.to change(teacher, :trn).to("abcdef")
    end

    it "sets the access your teaching qualifications URL" do
      expect { call }.to change(
        teacher,
        :access_your_teaching_qualifications_url,
      ).to("https://aytq.com")
    end

    it "sends an email" do
      expect { call }.to have_enqueued_mail(
        TeacherMailer,
        :application_awarded,
      ).with(params: { application_form: }, args: [])
    end

    it "changes the status" do
      expect { call }.to change(application_form, :stage).to("completed")
    end

    it "sets the awarded at date" do
      freeze_time do
        expect { call }.to change(application_form, :awarded_at).to(
          Time.zone.now,
        )
      end
    end

    context "without a TRN" do
      let(:trn) { "" }

      it "raises an error" do
        expect { call }.to raise_error(AwardQTS::MissingTRN)
      end
    end
  end

  context "with a potential duplicate in QTS application form" do
    let(:application_form) do
      create(:application_form, :potential_duplicate_in_dqt, teacher:)
    end

    before { create(:dqt_trn_request, application_form:) }

    it "sets the TRN" do
      expect { call }.to change(teacher, :trn).to("abcdef")
    end

    it "sets the access your teaching qualifications URL" do
      expect { call }.to change(
        teacher,
        :access_your_teaching_qualifications_url,
      ).to("https://aytq.com")
    end

    it "sends an email" do
      expect { call }.to have_enqueued_mail(
        TeacherMailer,
        :application_awarded,
      ).with(params: { application_form: }, args: [])
    end

    it "changes the status" do
      expect { call }.to change(application_form, :stage).to("completed")
    end

    it "sets the awarded at date" do
      freeze_time do
        expect { call }.to change(application_form, :awarded_at).to(
          Time.zone.now,
        )
      end
    end

    context "without a TRN" do
      let(:trn) { "" }

      it "raises an error" do
        expect { call }.to raise_error(AwardQTS::MissingTRN)
      end
    end
  end

  context "with an awarded application form" do
    let(:application_form) { create(:application_form, :awarded, teacher:) }

    before { create(:dqt_trn_request, application_form:) }

    it "doesn't change the TRN" do
      expect { call }.to_not change(teacher, :trn)
    end

    it "doesn't change the access your teaching qualifications URL" do
      expect { call }.to_not change(
        teacher,
        :access_your_teaching_qualifications_url,
      )
    end

    it "doesn't send an email" do
      expect { call }.to_not have_enqueued_mail(
        TeacherMailer,
        :application_awarded,
      )
    end

    it "doesn't change the stage" do
      expect { call }.to_not change(application_form, :stage)
    end

    it "doesn't change the awarded at date" do
      expect { call }.to_not change(application_form, :awarded_at)
    end
  end
end
