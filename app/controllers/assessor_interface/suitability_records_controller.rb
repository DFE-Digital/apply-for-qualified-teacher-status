# frozen_string_literal: true

require "pagy/extras/array"

module AssessorInterface
  class SuitabilityRecordsController < BaseController
    include Pagy::Backend

    before_action only: %i[index new create] do
      authorize %i[assessor_interface suitability_record]
    end

    def index
      @pagy, @records =
        pagy_array(
          SuitabilityRecord.includes(
            :names,
            :emails,
            :application_forms,
          ).sort_by(&:name),
        )

      render layout: "full_from_desktop"
    end

    def new
      @form = SuitabilityRecordForm.new
    end

    def create
      @form =
        SuitabilityRecordForm.new(
          form_params.merge(
            suitability_record: SuitabilityRecord.new,
            user: current_staff,
          ),
        )

      if @form.save
        redirect_to action: :index
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @form =
        SuitabilityRecordForm.new(
          suitability_record:,
          aliases:
            suitability_record.names.map(&:value).sort -
              [suitability_record.name],
          location: CountryCode.to_location(suitability_record.country_code),
          date_of_birth: suitability_record.date_of_birth,
          emails: suitability_record.emails.map(&:value),
          name: suitability_record.name,
          note: suitability_record.note,
          references:
            suitability_record.application_forms.map(&:references).sort,
        )
    end

    def update
      if suitability_record.archived?
        suitability_record.update!(
          archived_at: nil,
          archived_by: nil,
          archive_note: "",
        )
        redirect_to [:edit, :assessor_interface, suitability_record]
        return
      end

      @form =
        SuitabilityRecordForm.new(
          form_params.merge(suitability_record:, user: current_staff),
        )

      if @form.save
        redirect_to action: :index
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def archive
      @form = ArchiveSuitabilityRecordForm.new(suitability_record:)
    end

    def destroy
      @form =
        ArchiveSuitabilityRecordForm.new(
          archive_form_params.merge(suitability_record:, user: current_staff),
        )

      if @form.save
        redirect_to action: :index
      else
        render :archive, status: :unprocessable_entity
      end
    end

    private

    def form_params
      params.require(:assessor_interface_suitability_record_form).permit(
        :location,
        :date_of_birth,
        :name,
        :note,
        aliases: [],
        emails: [],
        references: [],
      )
    end

    def archive_form_params
      params.require(
        :assessor_interface_archive_suitability_record_form,
      ).permit(:note)
    end

    def suitability_record
      @suitability_record ||=
        authorize [:assessor_interface, SuitabilityRecord.find(params[:id])]
    end
  end
end
