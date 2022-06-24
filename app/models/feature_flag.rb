class FeatureFlag
  include ActiveModel::Model

  attr_accessor :description, :name, :owner

  DISABLED_IN_PRODUCTION = %i[service_open].freeze

  PERMANENT_SETTINGS = [
    [
      :service_open,
      "Allow users to access the service without HTTP basic auth. Should be " \
        "inactive on production, and active on all other environments.",
      "Thomas Leese"
    ],
    [
      :staff_http_basic_auth,
      "Allow signing in as a staff user using HTTP Basic authentication. " \
        "This is useful before staff users have been created, but should " \
        "otherwise be inactive.",
      "Thomas Leese"
    ]
  ].freeze

  TEMPORARY_FEATURE_FLAGS = [
    [
      :service_start,
      "Allow users to use the service, rather than being sent to the " \
        "legacy mutual recognition site",
      "Thomas Leese"
    ]
  ].freeze

  FEATURES =
    (PERMANENT_SETTINGS + TEMPORARY_FEATURE_FLAGS)
      .to_h do |name, description, owner|
        [name, FeatureFlag.new(description:, name:, owner:)]
      end
      .with_indifferent_access
      .freeze

  def self.activate(feature_name)
    raise unless feature_name.in?(FEATURES)

    sync_with_database(feature_name, true)
  end

  def self.deactivate(feature_name)
    raise unless feature_name.in?(FEATURES)

    sync_with_database(feature_name, false)
  end

  def self.active?(feature_name)
    raise unless feature_name.in?(FEATURES)

    feature_statuses[feature_name].presence || false
  end

  def self.sync_with_database(feature_name, active)
    feature = Feature.find_or_initialize_by(name: feature_name)
    feature.active = active

    feature.save!
  end

  def self.disabled_in_production?(feature_name)
    raise unless feature_name.in?(FEATURES)
    return false unless HostingEnvironment.production?

    feature_name.to_sym.in?(DISABLED_IN_PRODUCTION)
  end

  def self.feature_statuses
    Feature
      .where(name: FEATURES.keys)
      .pluck(:name, :active)
      .to_h
      .with_indifferent_access
  end
end
