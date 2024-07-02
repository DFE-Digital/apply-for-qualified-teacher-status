# frozen_string_literal: true

# == Schema Information
#
# Table name: uploads
#
#  id                  :bigint           not null, primary key
#  filename            :string           not null
#  malware_scan_result :string           default("pending"), not null
#  translation         :boolean          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  document_id         :bigint           not null
#
# Indexes
#
#  index_uploads_on_document_id  (document_id)
#
# Foreign Keys
#
#  fk_rails_...  (document_id => documents.id)
#
FactoryBot.define do
  factory :upload do
    association :document

    filename { Faker::File.file_name(ext: "pdf") }

    attachment do
      Rack::Test::UploadedFile.new(
        "spec/fixtures/files/upload.pdf",
        "application/pdf",
      )
    end

    translation { false }

    trait :translation do
      translation { true }
    end

    trait :clean do
      malware_scan_result { "clean" }
    end

    trait :suspect do
      malware_scan_result { "suspect" }
    end
  end
end
