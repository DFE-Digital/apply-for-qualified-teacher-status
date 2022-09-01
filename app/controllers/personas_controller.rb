class PersonasController < ApplicationController
  include EligibilityCurrentNamespace

  before_action :ensure_feature_active
  before_action :load_teacher_personas

  def index
    @staff = Staff.all
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
    unless FeatureFlag.active?(:personas)
      flash[:warning] = "Personas feature not active."
      redirect_to :root
    end
  end

  TEACHER_PERSONAS =
    %w[online written none]
      .product(%w[online written none], [true, false])
      .tap { |personas| personas.insert(2, *personas.slice!(8, 2)) }
      .map do |status_check, sanction_check, submitted|
        { status_check:, sanction_check:, submitted: }
      end

  def load_teacher_personas
    all_teachers =
      Teacher.includes(
        application_form: {
          region: [],
          documents: :uploads,
          qualifications: {
            documents: :uploads
          },
          work_histories: []
        }
      ).order(:id)

    @teacher_personas =
      TEACHER_PERSONAS.filter_map do |persona|
        found_teacher =
          all_teachers.find do |teacher|
            application_form = teacher.application_form
            next false if application_form.blank?

            region = application_form.region

            region.status_check == persona[:status_check] &&
              region.sanction_check == persona[:sanction_check] &&
              application_form.submitted? == persona[:submitted]
          end

        persona.merge(teacher: found_teacher) if found_teacher
      end
  end
end
