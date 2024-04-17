# frozen_string_literal: true

class ConfigurationSync::Importer
  include ServicePattern

  def initialize(file:)
    @data = JSON.parse(file.read).deep_symbolize_keys
  end

  def call
    data[:countries].each { |record| deserialise_country(record) }

    data[:english_language_providers].each do |record|
      deserialise_english_language_provider(record)
    end

    data[:regions].each { |record| deserialise_region(record) }
  end

  private

  attr_reader :data

  def deserialise_country(record)
    Country.find_or_initialize_by(code: record[:code]).update!(
      record.except(:code),
    )
  end

  def deserialise_english_language_provider(record)
    EnglishLanguageProvider.find_or_initialize_by(name: record[:name]).update!(
      record.except(:name),
    )
  end

  def deserialise_region(record)
    country = Country.find_by!(code: record[:country_code])
    Region.find_or_initialize_by(country:, name: record[:name]).update!(
      record.except(:country_code, :name),
    )
  end
end
