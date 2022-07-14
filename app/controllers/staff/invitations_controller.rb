class Staff::InvitationsController < Devise::InvitationsController
  include StaffCurrentNamespace

  layout "two_thirds"

  protect_from_forgery prepend: true

  # GET /resource/invitation/new
  # def new
  #   super
  # end

  # POST /resource/invitation
  # def create
  #   super
  # end

  # GET /resource/invitation/accept?invitation_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/invitation
  # def update
  #   super
  # end

  # GET /resource/invitation/remove?invitation_token=abcdef
  # def destroy
  #   super
  # end

  protected

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
