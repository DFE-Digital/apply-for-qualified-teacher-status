# frozen_string_literal: true

require "rails_helper"

RSpec.describe StaffNavigationHelper do
  let(:current_staff) { create(:staff) }
  let(:current_namespace) { "assessor" }

  def section_texts(sections)
    sections.map { |section| section[:text] }
  end

  def item_texts(sections, section_text)
    sections.find { |section| section[:text] == section_text }[
      :items
    ].map { |item| item[:text] }
  end

  describe "#staff_navigation_sections" do
    subject(:sections) { staff_navigation_sections }

    context "without a signed in staff member" do
      let(:current_staff) { nil }

      it { is_expected.to be_empty }
    end

    context "in the teacher namespace" do
      let(:current_namespace) { "teacher" }

      it { is_expected.to be_empty }
    end

    context "with a staff member who has no extra permissions" do
      it "only includes the sections everyone can see" do
        expect(section_texts(sections)).to eq(%w[Applications Monitoring])
      end

      it "includes the monitoring items" do
        expect(item_texts(sections, "Monitoring")).to eq(
          ["Email failures", "SLA status"],
        )
      end

      it "includes the application items" do
        expect(item_texts(sections, "Applications")).to eq(%w[Submitted Drafts])
      end
    end

    context "with a staff member who has all permissions" do
      let(:current_staff) do
        create(
          :staff,
          :with_assess_permission,
          :with_manage_staff_permission,
          :with_support_console_permission,
        )
      end

      before { FeatureFlags::FeatureFlag.activate(:suitability) }
      after { FeatureFlags::FeatureFlag.deactivate(:suitability) }

      it "includes every section in order" do
        expect(section_texts(sections)).to eq(
          [
            "Applications",
            "Records",
            "Monitoring",
            "Support console",
            "Developer tools",
          ],
        )
      end

      it "includes the records items" do
        expect(item_texts(sections, "Records")).to eq(
          ["Suitability records", "Email domain records"],
        )
      end

      it "includes the support console items" do
        expect(item_texts(sections, "Support console")).to eq(
          ["Countries", "English language test providers", "Manage access"],
        )
      end

      it "includes the full monitoring items including service feedback" do
        expect(item_texts(sections, "Monitoring")).to eq(
          ["Email failures", "SLA status", "Service feedback"],
        )
      end

      it "includes the developer tools items" do
        expect(item_texts(sections, "Developer tools")).to eq(
          ["Features", "Solid queue"],
        )
      end

      it "marks Solid queue to open in a new tab" do
        solid_queue = sections.last[:items].last
        expect(solid_queue[:new_tab]).to be(true)
      end

      it "keeps the Applications destination and adds both sub navigation links" do
        applications = sections.first
        destination = applications[:href] || applications[:items].first[:href]
        expect(destination).to eq(
          main_app.assessor_interface_application_forms_path,
        )
        expect(applications[:items].map { |item| item[:href] }).to eq(
          [
            main_app.assessor_interface_application_forms_path,
            main_app.assessor_interface_draft_application_forms_path,
          ],
        )
      end
    end

    context "with the suitability feature flag off" do
      let(:current_staff) { create(:staff, :with_assess_permission) }

      before { FeatureFlags::FeatureFlag.deactivate(:suitability) }

      it "leaves out suitability records" do
        expect(item_texts(sections, "Records")).to eq(["Email domain records"])
      end
    end
  end

  describe "#staff_navigation_item_active?" do
    before { request.path = path }

    let(:item) do
      {
        text: "Countries",
        href: "/support/countries",
        match: %w[/support/countries /support/regions],
      }
    end

    context "on the item's own page" do
      let(:path) { "/support/countries" }

      it { expect(staff_navigation_item_active?(item)).to be(true) }
    end

    context "on a page that matches one of its extra paths" do
      let(:path) { "/support/regions/1/edit" }

      it { expect(staff_navigation_item_active?(item)).to be(true) }
    end

    context "on an unrelated page" do
      let(:path) { "/support/features" }

      it { expect(staff_navigation_item_active?(item)).to be(false) }
    end

    context "with a section that has no href" do
      let(:path) { "/support/countries" }

      it do
        expect(
          staff_navigation_item_active?({ text: "Records", items: [] }),
        ).to be(false)
      end
    end
  end

  describe "#current_staff_navigation_section" do
    subject(:current_section) do
      current_staff_navigation_section(staff_navigation_sections)
    end

    let(:current_staff) { create(:staff, :with_support_console_permission) }

    before { request.path = path }

    context "on an application page" do
      let(:path) { "#{main_app.assessor_interface_application_forms_path}/123" }

      it { expect(current_section[:text]).to eq("Applications") }
    end

    context "on the draft application list" do
      let(:path) { main_app.assessor_interface_draft_application_forms_path }

      it "activates Applications and only the Drafts item" do
        expect(current_section[:text]).to eq("Applications")
        expect(
          current_section[:items]
            .select { |item| staff_navigation_item_active?(item) }
            .map { |item| item[:text] },
        ).to eq(["Drafts"])
      end
    end

    context "on a draft application page" do
      let(:path) do
        "#{main_app.assessor_interface_draft_application_forms_path}/123"
      end

      it "activates Applications and only the Drafts item" do
        expect(current_section[:text]).to eq("Applications")
        expect(
          current_section[:items]
            .select { |item| staff_navigation_item_active?(item) }
            .map { |item| item[:text] },
        ).to eq(["Drafts"])
      end
    end

    context "on the submitted application list" do
      let(:path) { main_app.assessor_interface_application_forms_path }

      it "activates only the Submitted item" do
        expect(
          current_section[:items]
            .select { |item| staff_navigation_item_active?(item) }
            .map { |item| item[:text] },
        ).to eq(["Submitted"])
      end
    end

    context "on a regions page" do
      let(:path) { "/support/regions/1/edit" }

      it { expect(current_section[:text]).to eq("Support console") }
    end

    context "on the features page" do
      let(:path) { main_app.support_interface_feature_flags_path }

      it { expect(current_section[:text]).to eq("Developer tools") }
    end

    context "on a page outside the navigation" do
      let(:path) { "/assessor/something-else" }

      it { is_expected.to be_nil }
    end
  end
end
