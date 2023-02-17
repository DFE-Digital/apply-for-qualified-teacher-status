# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExpireReferenceRequestsJob, type: :job do
  it_behaves_like "a expire requestables job", :reference_request
end
