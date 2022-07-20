class TeacherInterface::WorkHistoriesController < TeacherInterface::BaseController
  before_action :load_application_form
  before_action :load_work_history, only: %i[edit update destroy]

  def index
    @work_histories = @application_form.work_histories.ordered

    if @work_histories.empty?
      redirect_to [:new, :teacher_interface, @application_form, :work_history]
    end
  end

  def new
    @work_history = WorkHistory.new(application_form: @application_form)
  end

  def create
    unless params.include?(:work_history)
      if ActiveModel::Type::Boolean.new.cast(params[:add_another])
        redirect_to [:new, :teacher_interface, @application_form, :work_history]
      else
        redirect_to [:teacher_interface, @application_form]
      end

      return
    end

    @work_history = @application_form.work_histories.new(work_history_params)
    if @work_history.save
      redirect_to [:teacher_interface, @application_form, :work_histories]
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @work_history.update(work_history_params)
      redirect_to [:teacher_interface, @application_form, :work_histories]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy!
    redirect_to [:teacher_interface, @application_form, :work_histories]
  end

  private

  def load_work_history
    @work_history = @application_form.work_histories.find(params[:id])
  end

  def work_history_params
    params.require(:work_history).permit(
      :city,
      :country,
      :email,
      :end_date,
      :job,
      :school_name,
      :start_date,
      :still_employed
    )
  end
end
