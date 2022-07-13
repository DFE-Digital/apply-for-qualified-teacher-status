module TeacherInterface
  class BaseController < ApplicationController
    include TeacherCurrentNamespace

    before_action :authenticate_teacher!
  end
end
