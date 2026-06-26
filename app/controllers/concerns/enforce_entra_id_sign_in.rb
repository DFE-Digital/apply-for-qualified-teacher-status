# frozen_string_literal: true

module EnforceEntraIdSignIn
  extend ActiveSupport::Concern

  private

  def enforce_entra_id_sign_in
    if FeatureFlags::FeatureFlag.active?(:sign_in_with_active_directory)
      redirect_to root_path
    end
  end
end
