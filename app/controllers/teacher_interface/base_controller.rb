class TeacherInterface::BaseController < ApplicationController
  include TeacherCurrentNamespace

  layout "two_thirds"

  before_action :authenticate_teacher!
end
