class FeatureFlag
  include ActiveModel::Model

  attr_accessor :description, :name, :owner

  DISABLED_IN_PRODUCTION = %i[personas service_open staff_test_user].freeze

  SETTINGS = [
    [
      :personas,
      "Allow signing in as a 'persona', making it easy to perform " \
        "acceptance testing by impersonating a particular user, e.g. teacher, " \
        "assessor, or admin.",
      "Thomas Leese",
    ],
    [
      :service_open,
      "Allow users to access the service without HTTP basic auth. Should be " \
        "inactive on production, and active on all other environments.",
      "Thomas Leese",
    ],
    [
      :staff_test_user,
      "Add extra user with access the eligibility checker for user research. " \
        "When service_open is deactivated, and this flag is enabled, the user will have " \
        "full access to the service. Should be inactive on production.",
      "David Feetenby",
    ],
    [
      :teacher_applications,
      "Allow starting an application on this service directly after " \
        "completing an eligibility check.",
      "Thomas Leese",
    ],
  ].freeze

  FEATURES =
    SETTINGS
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
