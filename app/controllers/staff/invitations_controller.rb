class Staff::InvitationsController < Devise::InvitationsController
  include StaffCurrentNamespace

  layout "two_thirds"

  before_action :configure_permitted_parameters
  protect_from_forgery prepend: true

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:invite, keys: [:name])
  end

  def invite_resource(&block)
    if current_inviter.is_a?(AnonymousSupportUser)
      resource_class.invite!(invite_params, &block)
    else
      super
    end
  end

  def after_invite_path_for(inviter, invitee)
    invitee.is_a?(Staff) ? support_interface_staff_index_path : super
  end

  def after_accept_path_for(resource)
    resource.is_a?(Staff) ? support_interface_staff_index_path : super
  end
end
