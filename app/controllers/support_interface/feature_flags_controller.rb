# frozen_string_literal: true

class SupportInterface::FeatureFlagsController < SupportInterface::BaseController
  before_action { authorize %i[support_interface feature_flag] }
end
