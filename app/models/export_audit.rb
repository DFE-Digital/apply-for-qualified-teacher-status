# frozen_string_literal: true

# == Schema Information
#
# Table name: export_audits
#
#  id             :bigint           not null, primary key
#  export_type    :string           not null
#  filter_params  :jsonb
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  exported_by_id :bigint           not null
#
# Indexes
#
#  index_export_audits_on_exported_by_id  (exported_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (exported_by_id => staff.id)
#
class ExportAudit < ApplicationRecord
  belongs_to :exported_by, class_name: "Staff"

  enum :export_type, { application_forms: "application_forms" }
end
