# frozen_string_literal: true

class StaticController < ApplicationController
  include EligibilityCurrentNamespace

  layout "two_thirds"
end
