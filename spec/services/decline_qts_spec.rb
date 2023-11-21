# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeclineQTS do
  let(:teacher) { create(:teacher) }
  let(:user) { create(:staff, :confirmed) }

  subject(:call) { described_class.call(application_form:, user:) }

  context "with an application form" do
    let(:application_form) { create(:application_form, :submitted, teacher:) }

    it "sends an email" do
      expect { call }.to have_enqueued_mail(
        TeacherMailer,
        :application_declined,
      ).with(params: { teacher: }, args: [])
    end

    it "changes the stage" do
      expect { call }.to change(application_form, :stage).to("completed")
    end

    it "changes the statuses" do
      expect { call }.to change(application_form, :statuses).to(%w[declined])
    end

    it "sets the declined at date" do
      freeze_time do
        expect { call }.to change(application_form, :declined_at).to(
          Time.zone.now,
        )
      end
    end
  end

  context "with a declined application form" do
    let(:application_form) { create(:application_form, :declined, teacher:) }

    it "doesn't send an email" do
      expect { call }.to_not have_enqueued_mail(
        TeacherMailer,
        :application_declined,
      )
    end

    it "doesn't change the stage" do
      expect { call }.to_not change(application_form, :stage)
    end

    it "doesn't change the declined at date" do
      expect { call }.to_not change(application_form, :declined_at)
    end
  end
end
