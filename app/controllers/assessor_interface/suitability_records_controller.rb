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

    def suitability_record
      @suitability_record ||=
        authorize [:assessor_interface, SuitabilityRecord.find(params[:id])]
    end
  end
end
