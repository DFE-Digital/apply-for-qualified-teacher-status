module Dqt
  class TrnRequestParams
    ### params https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L671
    # firstName (string, required)
    # middleName (string)
    # lastName (string, required)
    # birthDate (string, required)
    # emailAddress (string)
    # address: (object)
    #   addressLine1 (string)
    #   addressLine2 (string)
    #   addressLine3 (string)
    #   city (string)
    #   postalCode (string)
    #   country (string)
    # genderCode: https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L649-L656
    # initialTeacherTraining: (object)
    #   providerUkprn: (string)
    #   programmeStartDate: (string, required) #   programmeEndDate: (string, required)
    #   programmeType: (string, required) https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L943-L968
    #   subject1: (string)
    #   subject2: (string)
    #   subject3: (string)
    #   ageRangeFrom: (integer)
    #   ageRangeTo: (integer)
    #   ittQualificationType: https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L991-L1060
    #   ittQualificationAim: https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L983-L987
    #   ittQualificationType: https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L1019-L1059
    # qualification: (object)
    #   providerUkprn: (string)
    #   countryCode: (string)
    #   subject: (string)
    #   subject2: (string)
    #   subject3: (string)
    #   class: https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L574-L593
    #   date: (string)
    #   heQualificationType: https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L840-L930
    # husId: (string)
    def initialize(application_form:)
      @application_form = application_form
      @teacher = application_form.teacher
    end

    def as_hash
      {
        firstName: application_form.given_names,
        middleName: nil,
        lastName: application_form.family_name,
        birthDate: application_form.date_of_birth.iso8601,
        emailAddress: teacher.email,
        address: {}, # we don't collect address
        genderCode: "NotAvailable",
        initialTeacherTraining: initial_teacher_training_params,
        qualification: qualification_params,
      }
    end

    private

    attr_reader :application_form, :teacher

    #   providerUkprn: (string)
    #   programmeStartDate: (string, required)
    #   programmeEndDate: (string, required)
    #   programmeType: (string, required) https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L943-L968
    #   subject1: (string)
    #   subject2: (string)
    #   subject3: (string)
    #   ageRangeFrom: (integer)
    #   ageRangeTo: (integer)
    #   ittQualificationType: https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L991-L1060
    #   ittQualificationAim: https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L983-L987
    #   ittQualificationType: https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L1019-L1059
    def initial_teacher_training_params
      {
        providerUkprn: nil, # We'll never have one of these so this will need work on the DQT end
        programmeStartDate: teaching_qualification.start_date,
        programmeEndDate: teaching_qualification.complete_date,
        programmeType: "OverseasTrainedTeacherProgramme",
        subject1:  application_form.subjects[0],
        subject2:  application_form.subjects[1],
        subject3:  application_form.subjects[2],
        ageRangeFrom: application_form.age_range_min,
        ageRangeTo: application_form.age_range_max,
      }
    end

    #https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L803-L837
    # qualification: (object)
    #   providerUkprn: (string)
    #   countryCode: (string)
    #   subject: (string)
    #   subject2: (string)
    #   subject3: (string)
    #   class: https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L574-L593
    #   date: (string)
    #   heQualificationType: https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L840-L930
    def qualification_params
      return {} unless university_degree.present?

      {
        providerUkprn: nil,
        countryCode: country_code_for(university_degree.institution_country),
        subject: university_degree.title,
        class: "NotKnown",#https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L574-L593
        date: university_degree.certificate_date,
        heQualificationType: "Unknown"  #https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L840-L930
      }
    end

    def country_code_for(_country)
      # TODO: mapping these. Probably need to make country an autocomplete
      # register's mapping -> https://github.com/DFE-Digital/register-trainee-teachers/blob/main/app/lib/hesa/code_sets/countries.rb
      "CA" # hard code Canada for now
    end

    def teaching_qualification
      @teaching_qualification ||= application_form.qualifications.all.find(&:is_teaching_qualification?)
    end

    def university_degree
      #we're just going to send the first one we find
      @university_degree ||= application_form.qualifications.all.find(&:is_university_degree?)
    end
  end
end
