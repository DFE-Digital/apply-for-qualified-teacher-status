# frozen_string_literal: true

namespace :documents do
  desc "Sets the completed value on the documents."
  task set_completed: :environment do
    Document
      .joins(:uploads)
      .group("documents.id")
      .having("COUNT(uploads.id) > 1")
      .update_all(completed: true)

    Document
      .joins(:uploads)
      .group("documents.id")
      .having("COUNT(uploads.id) <= 1")
      .update_all(completed: false)

    puts "Completed documents: #{Document.completed.count}"
    puts "Incomplete documents: #{Document.not_completed.count}"
  end
end
