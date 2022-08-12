module Dqt
  class RecommendForAward
    include ServicePattern

    def initialize(teacher:, assessment_date:)
      @teacher = teacher
      @date_of_birth  = teacher.date_of_birth
      @trn = teacher.trn
      @assessment_date = assessment_date
    end

    def call
      path = "/v2/teachers/#{trn}/itt-outcome?birthdate=#{date_of_birth}"
      body = {
        ittProviderUkprn: "1001234", # we don't have this and it's currently required
        outcome: "Pass",
        assessmentDate: assessment_date.iso8601
      }.to_json

      # handle response https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L58-L68
      Client.put(path, body:)
    end

    private

    attr_reader :teacher, :date_of_birth, :trn, :assessment_date
  end
end
