# frozen_string_literal: true

class ClearSolidQueueFinishedJobsJob < ApplicationJob
  def perform
    SolidQueue::Job.clear_finished_in_batches(sleep_between_batches: 0.3)
  end
end
