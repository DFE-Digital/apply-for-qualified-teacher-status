class MigrateFeatureFlags < ActiveRecord::Migration[7.0]
  def change
    Feature.all.each do |feature|
      FeatureFlags::Feature.create!(feature.attributes)
    end
  end
end
