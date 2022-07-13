class AuthenticationFailureApp < Devise::FailureApp
  def route(scope)
    scope.to_sym == :teacher ? :new_teacher_registration_path : super
  end
end
