# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateWorkHistoryContact do
  subject(:call) do
    described_class.call(
      work_history:,
      user:,
      name: new_name,
      job: new_job,
      email: new_email,
    )
  end

  let(:work_history) { create(:work_history, :completed) }
  let(:user) { create(:staff) }
  let(:new_name) { "New name" }
  let(:new_job) { "New job" }
  let(:new_email) { "new@example.com" }

  it "changes the contact name" do
    expect { call }.to change(work_history, :contact_name).to(new_name)
  end

  it "changes the contact job" do
    expect { call }.to change(work_history, :contact_job).to(new_job)
  end

  it "changes the contact email" do
    expect { call }.to change(work_history, :contact_email).to(new_email)
  end

  it "changes the canonical contact email" do
    expect { call }.to change(work_history, :canonical_contact_email).to(
      new_email,
    )
  end

  it "changes the contact email domain" do
    expect { call }.to change(work_history, :contact_email_domain).to(
      "example.com",
    )
  end

  it "doesn't send any emails" do
    expect { call }.not_to have_enqueued_mail(
      RefereeMailer,
      :reference_requested,
    )
  end

  it "records timeline events" do
    expect { call }.to have_recorded_timeline_event(
      :information_changed,
      creator: user,
      work_history:,
    )
  end

  context "when there are no eligibility domain matches" do
    it "does not match to any eligibility domains" do
      call

      expect(work_history.reload.eligibility_domain).to be_nil
    end

    it "does not EligibilityDomains::ApplicationFormsCounterJob" do
      expect { call }.not_to have_enqueued_job(
        EligibilityDomains::ApplicationFormsCounterJob,
      )
    end
  end

  context "when the work history has existing eligibility domain and changes email" do
    let(:eligibility_domain) { create(:eligibility_domain) }

    before { work_history.update!(eligibility_domain:) }

    it "removes existing connection with eligibility domain" do
      call

      expect(work_history.reload.eligibility_domain).to be_nil
    end

    it "enqueues EligibilityDomains::ApplicationFormsCounterJob matched existing eligibility domain" do
      expect { call }.to have_enqueued_job(
        EligibilityDomains::ApplicationFormsCounterJob,
      ).with(eligibility_domain)
    end

    context "with new email matching another eligibility domain record" do
      let!(:new_eligibility_domain) do
        create(:eligibility_domain, domain: "example.com")
      end

      it "matches with the new eligibility domain" do
        call

        expect(work_history.reload.eligibility_domain).to eq(
          new_eligibility_domain,
        )
      end

      it "enqueues EligibilityDomains::ApplicationFormsCounterJob new and existing eligibility domains" do
        expect { call }.to have_enqueued_job(
          EligibilityDomains::ApplicationFormsCounterJob,
        ).with(eligibility_domain).and have_enqueued_job(
                EligibilityDomains::ApplicationFormsCounterJob,
              ).with(new_eligibility_domain)
      end
    end
  end

  context "when there is a eligibility domain that is a match" do
    let!(:eligibility_domain) do
      create :eligibility_domain, domain: "example.com"
    end

    it "matches to any application forms" do
      call

      expect(work_history.reload.eligibility_domain).to eq(eligibility_domain)
    end

    it "enqueues EligibilityDomains::ApplicationFormsCounterJob matched eligibility domain" do
      expect { call }.to have_enqueued_job(
        EligibilityDomains::ApplicationFormsCounterJob,
      ).with(eligibility_domain)
    end
  end

  context "when there is a eligibility domain that is not a match" do
    before { create :eligibility_domain }

    it "does not match to any eligibility domains" do
      call

      expect(work_history.eligibility_domain).to be_nil
    end

    it "does not EligibilityDomains::ApplicationFormsCounterJob" do
      expect { call }.not_to have_enqueued_job(
        EligibilityDomains::ApplicationFormsCounterJob,
      )
    end
  end

  describe "when references already sent out" do
    before { create(:requested_reference_request, work_history:) }

    it "sends an email to the referee" do
      expect { call }.to have_enqueued_mail(RefereeMailer, :reference_requested)
    end

    it "sends an email to the teacher" do
      expect { call }.to have_enqueued_mail(
        TeacherMailer,
        :references_requested,
      )
    end
  end
end
