class AnonymousSupportUser
  def has_invitations_left?
    true
  end

  def devise_scope
    :staff
  end
end
