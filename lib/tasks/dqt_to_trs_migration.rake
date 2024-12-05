# frozen_string_literal: true

require "ruby-progressbar"

namespace :dqt_to_trs_migration do
  desc "Backfill the trs_trn_requests table with what is within dqt_trn_requests"
  task replace_dqt_trn_requests_table_with_trs_trn_requests: :environment do
    progressbar =
      ProgressBar.create!(name: "Creation", count: DQTTRNRequest.count)

    ActiveRecord::Base.transaction do
      DQTTRNRequest.find_each do |dqt_trn_request|
        progressbar.increment

        TRSTRNRequest.create!(
          potential_duplicate: dqt_trn_request.potential_duplicate,
          state: dqt_trn_request.state,
          created_at: dqt_trn_request.created_at,
          updated_at: dqt_trn_request.updated_at,
          application_form_id: dqt_trn_request.application_form_id,
          request_id: dqt_trn_request.request_id,
        )
      end
    end
  end
end
