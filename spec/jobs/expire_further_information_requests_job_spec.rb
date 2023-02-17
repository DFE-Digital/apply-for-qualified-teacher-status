# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExpireFurtherInformationRequestsJob, type: :job do
  it_behaves_like "a expire requestables job", :further_information_request
end
