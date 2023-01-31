# frozen_string_literal: true

class SupportInterface::EnglishLanguageProvidersController < SupportInterface::BaseController
  def index
    @english_language_providers = EnglishLanguageProvider.order(:created_at)
  end

  def edit
    @english_language_provider = EnglishLanguageProvider.find(params[:id])
  end

  def update
    @english_language_provider = EnglishLanguageProvider.find(params[:id])

    if @english_language_provider.update(english_language_provider_params)
      flash[
        :success
      ] = "Successfully updated ‘#{@english_language_provider.name}’"

      redirect_to support_interface_english_language_providers_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def english_language_provider_params
    params.require(:english_language_provider).permit(
      :name,
      :b2_level_requirement,
      :reference_name,
      :reference_hint,
      :check_url,
    )
  end
end
