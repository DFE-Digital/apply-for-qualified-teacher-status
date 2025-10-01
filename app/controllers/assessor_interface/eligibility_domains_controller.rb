# frozen_string_literal: true

require "pagy/extras/array"

module AssessorInterface
  class EligibilityDomainsController < BaseController
    include Pagy::Backend

    before_action :ensure_active, only: %i[edit_archive update_archive]
    before_action :ensure_archived, only: %i[edit_reactivate update_reactivate]

    before_action only: %i[index new create] do
      authorize %i[assessor_interface eligibility_domain]
    end

    def index
      @pagy, @records =
        pagy(
          EligibilityDomain.includes(:application_forms).order(
            archived_at: :desc,
            application_forms_count: :desc,
          ),
        )

      render layout: "full_from_desktop"
    end

    def new
      @form = CreateEligibilityDomainForm.new
    end

    def create
      @form =
        CreateEligibilityDomainForm.new(
          eligibility_domain_form_params.merge(created_by: current_staff),
        )

      if @form.save
        redirect_to action: :index
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @form = CreateNoteForm.new(eligibility_domain:)
    end

    def update
      @form =
        CreateNoteForm.new(
          note_form_params.merge(eligibility_domain:, author: current_staff),
        )

      if @form.save
        redirect_to action: :index
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def edit_archive
      @form = ArchiveEligibilityDomainForm.new(eligibility_domain:)
    end

    def update_archive
      @form =
        ArchiveEligibilityDomainForm.new(
          archive_form_params.merge(
            eligibility_domain:,
            archived_by: current_staff,
          ),
        )

      if @form.save
        redirect_to action: :index
      else
        render :edit_archive, status: :unprocessable_entity
      end
    end

    def edit_reactivate
      @form = ReactivateEligibilityDomainForm.new(eligibility_domain:)
    end

    def update_reactivate
      @form =
        ReactivateEligibilityDomainForm.new(
          reactivate_form_params.merge(
            eligibility_domain:,
            reactivated_by: current_staff,
          ),
        )

      if @form.save
        redirect_to action: :index
      else
        render :edit_reactivate, status: :unprocessable_entity
      end
    end

    private

    def eligibility_domain_form_params
      params.require(:assessor_interface_create_eligibility_domain_form).permit(
        :domain,
        :note,
      )
    end

    def note_form_params
      params.require(:assessor_interface_create_note_form).permit(:text)
    end

    def archive_form_params
      params.require(
        :assessor_interface_archive_eligibility_domain_form,
      ).permit(:note)
    end

    def reactivate_form_params
      params.require(
        :assessor_interface_reactivate_eligibility_domain_form,
      ).permit(:note)
    end

    def eligibility_domain
      @eligibility_domain ||=
        authorize [:assessor_interface, EligibilityDomain.find(params[:id])]
    end

    def ensure_active
      return if eligibility_domain.archived_at.nil?

      flash[:alert] = "Record is already archived"
      redirect_to [:edit, :assessor_interface, eligibility_domain]
    end

    def ensure_archived
      return if eligibility_domain.archived_at.present?

      flash[:alert] = "Record is already active"
      redirect_to [:edit, :assessor_interface, eligibility_domain]
    end
  end
end
