# frozen_string_literal: true

class ExpireRequestableJob < ApplicationJob
  def perform(requestable)
    ExpireRequestable.call(requestable:)
  end
end
