# frozen_string_literal: true

class SupportInterface::FeatureFlagsController < SupportInterface::BaseController
  def index
    @features = FeatureFlag::FEATURES
  end

  def activate
    FeatureFlag.activate(params[:feature_name])

    flash[:success] = "Feature “#{feature_name}” activated"
    redirect_to support_interface_features_path
  end

  def deactivate
    FeatureFlag.deactivate(params[:feature_name])

    flash[:success] = "Feature “#{feature_name}” deactivated"
    redirect_to support_interface_features_path
  end

  private

  def feature_name
    params[:feature_name].humanize
  end
end
