# frozen_string_literal: true

class SupportInterface::EnglishLanguageProvidersController < SupportInterface::BaseController
  before_action :load_english_language_provider, except: :index

  def index
    authorize [:support_interface, EnglishLanguageProvider]
    @english_language_providers = EnglishLanguageProvider.order(:created_at)
  end

  def edit
  end

  def update
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

  def load_english_language_provider
    @english_language_provider = EnglishLanguageProvider.find(params[:id])
    authorize [:support_interface, @english_language_provider]
  end

  def english_language_provider_params
    params.require(:english_language_provider).permit(
      :name,
      :b2_level_requirement,
      :b2_level_requirement_prefix,
      :url,
      :reference_name,
      :reference_hint,
      :accepted_tests,
      :check_url,
      :other_information,
    )
  end
end
