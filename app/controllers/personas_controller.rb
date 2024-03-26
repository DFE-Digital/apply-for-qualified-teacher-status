# frozen_string_literal: true

class PersonasController < ApplicationController
  include EligibilityCurrentNamespace

  before_action :ensure_feature_active

  before_action :load_staff_personas,
                :load_teacher_personas,
                :load_eligible_personas,
                only: :index

  def index
    render layout: "full_from_desktop"
  end

  def eligible_sign_in
    region = Region.find(params[:id])

    eligibility_check =
      EligibilityCheck.create!(
        completed_at: Time.zone.now,
        country_code: region.country.code,
        degree: true,
        free_of_sanctions: true,
        qualification: true,
        region:,
        teach_children: true,
        work_experience: "over_20_months",
      )

    session[:eligibility_check_id] = eligibility_check.id

    redirect_to %i[eligibility_interface result]
  end

  def ineligible_sign_in
    eligibility_check =
      EligibilityCheck.create!(
        completed_at: Time.zone.now,
        country_code: INELIGIBLE_COUNTRY_CODES.sample,
      )

    session[:eligibility_check_id] = eligibility_check.id

    redirect_to %i[eligibility_interface result]
  end

  def staff_sign_in
    staff = Staff.find(params[:id])
    sign_in_and_redirect(staff)
  end

  def teacher_sign_in
    teacher = Teacher.find(params[:id])
    sign_in_and_redirect(teacher)
  end

  protected

  def after_sign_in_path_for(resource)
    case resource
    when Staff
      :assessor_interface_root
    when Teacher
      :teacher_interface_root
    end
  end

  private

  def ensure_feature_active
    unless FeatureFlags::FeatureFlag.active?(:personas)
      flash[:warning] = "Personas feature not active."
      redirect_to :root
    end
  end

  ELIGIBLE_PERSONAS =
    %w[online written none] # sanction_check
      .product(
        %w[online written none], # status_check
        [true, false], # application_form_skip_work_history
        [true, false], # teaching_authority_provides_written_statement
        [true, false], # reduced_evidence_accepted
      )
      .map do |persona|
        {
          sanction_check: persona[0],
          status_check: persona[1],
          application_form_skip_work_history: persona[2],
          teaching_authority_provides_written_statement: persona[3],
          reduced_evidence_accepted: persona[4],
        }
      end

  INELIGIBLE_COUNTRY_CODES = Country::CODES - Country.pluck(:code)

  def load_eligible_personas
    all_regions = Region.includes(:country).order(:id)

    @eligible_personas =
      ELIGIBLE_PERSONAS.filter_map do |persona|
        found_region =
          all_regions.find do |region|
            region.status_check == persona[:status_check] &&
              region.sanction_check == persona[:sanction_check] &&
              region.application_form_skip_work_history ==
                persona[:application_form_skip_work_history] &&
              region.teaching_authority_provides_written_statement ==
                persona[:teaching_authority_provides_written_statement] &&
              region.reduced_evidence_accepted ==
                persona[:reduced_evidence_accepted]
          end

        persona.merge(region: found_region) if found_region
      end
  end

  def load_staff_personas
    @staff_personas =
      Staff.order(
        assess_permission: :desc,
        change_name_permission: :desc,
        change_work_history_permission: :desc,
        reverse_decision_permission: :desc,
        support_console_permission: :desc,
        verify_permission: :desc,
        withdraw_permission: :desc,
        email: :asc,
      )
  end

  TEACHER_PERSONAS =
    %w[online written none]
      .product(
        %w[online written none],
        %w[
          draft
          not_started
          waiting_on_lops
          waiting_on_consent
          waiting_on_further_information
          awarded
          declined
        ],
      )
      .map do |status_check, sanction_check, stage_or_status|
        { status_check:, sanction_check:, stage_or_status: }
      end

  def load_teacher_personas
    all_application_forms =
      ApplicationForm.includes(
        :teacher,
        region: :country,
        documents: :uploads,
        qualifications: {
          documents: :uploads,
        },
        work_histories: [],
      ).order(:id)

    @teacher_personas =
      TEACHER_PERSONAS.filter_map do |persona|
        found_application_form =
          all_application_forms.find do |application_form|
            region = application_form.region

            unless region.status_check == persona[:status_check] &&
                     region.sanction_check == persona[:sanction_check]
              next
            end

            stage_or_status = persona[:stage_or_status]

            if stage_or_status == "waiting_on_lops" &&
                 !application_form.teaching_authority_provides_written_statement
              next
            end

            application_form.stage == stage_or_status ||
              application_form.statuses.include?(stage_or_status)
          end

        if (application_form = found_application_form)
          persona.merge(application_form:, teacher: application_form.teacher)
        end
      end
  end
end
