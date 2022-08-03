module TeacherInterface
  class QualificationsController < BaseController
    before_action :load_application_form
    before_action :load_qualification, only: %i[edit update destroy]

    def index
      @qualifications = application_form.qualifications.ordered

      if @qualifications.empty?
        redirect_to %i[new teacher_interface application_form qualification]
      end
    end

    def new
      @qualification = Qualification.new(application_form:)
    end

    def create
      unless params.include?(:qualification)
        if ActiveModel::Type::Boolean.new.cast(params[:add_another])
          redirect_to %i[new teacher_interface application_form qualification]
        else
          redirect_to %i[teacher_interface application_form]
        end

        return
      end

      @qualification = application_form.qualifications.new(qualification_params)
      if @qualification.save
        redirect_to_if_save_and_continue [
                                           :edit,
                                           :teacher_interface,
                                           :application_form,
                                           @qualification.certificate_document
                                         ]
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @qualification.update(qualification_params)
        redirect_to_if_save_and_continue %i[
                                           teacher_interface
                                           application_form
                                           qualifications
                                         ]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @qualification.destroy!
      redirect_to %i[teacher_interface application_form qualifications]
    end

    private

    def load_qualification
      @qualification = application_form.qualifications.find(params[:id])
    end

    def qualification_params
      params.require(:qualification).permit(
        :title,
        :institution_name,
        :institution_country,
        :start_date,
        :complete_date,
        :certificate_date
      )
    end
  end
end
