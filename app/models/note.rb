# frozen_string_literal: true

# == Schema Information
#
# Table name: notes
#
#  id                  :bigint           not null, primary key
#  text                :text             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint           not null
#  author_id           :bigint           not null
#
# Indexes
#
#  index_notes_on_application_form_id  (application_form_id)
#  index_notes_on_author_id            (author_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#  fk_rails_...  (author_id => staff.id)
#

class Note < ApplicationRecord
  belongs_to :application_form
  belongs_to :author, class_name: "Staff"

  validates :text, presence: true
end
