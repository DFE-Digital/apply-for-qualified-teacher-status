class Staff::InvitationsController < Devise::InvitationsController
  include StaffCurrentNamespace

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
end
