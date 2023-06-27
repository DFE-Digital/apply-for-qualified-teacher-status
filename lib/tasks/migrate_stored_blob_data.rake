desc "Migrate stored blob data from PaaS to AKS"
task migrate_stored_blob_data: :environment do
  uploads = Upload.where(migrated_to_aks: false).order(:created_at)

  count = uploads.count

  uploads.each_with_index do |upload, index|
    MigrateStoredBlobData.call(upload:)
    puts "Migrated #{index + 1}/#{count} uploads"
    sleep(2) # Avoid rate limiting
  end
end
