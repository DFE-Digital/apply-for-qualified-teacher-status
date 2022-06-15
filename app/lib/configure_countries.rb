class ConfigureCountries
  PRIVATE_BETA_REGIONS = [
    # Republic of Ireland
    {
      country_code: :IE,
      sanction_check: :written,
      status_check: :online,
      teaching_authority_certificate: "Letter of Professional Standing",
      teaching_authority_email_address: "info@teachingcouncil.ie",
      teaching_authority_address:
        "The Teaching Council\nBlock A\nMaynooth Business Campus\nMaynooth, Co. Kildare\nW23 Y7X0\nIreland"
    },
    # Poland
    {
      country_code: :PL,
      sanction_check: :written,
      status_check: :written,
      teaching_authority_certificate: "Letter of Confirmation",
      teaching_authority_email_address: "sekretariat.dko@mein.gov.pl",
      teaching_authority_address:
        "Ministry of Education and Science\nul. Aleja Jana Chrystiana Szucha 25\n00-918 Warsaw\nPoland"
    },
    # USA (Hawaii)
    {
      country_code: :US,
      name: "Hawaii",
      sanction_check: :online,
      status_check: :online
    },
    # Spain
    {
      country_code: :ES,
      sanction_check: :none,
      status_check: :written,
      teaching_authority_certificate: "Solicitud",
      teaching_authority_address:
        "Subdirectora General de Títulos y Ordenación\nSeguimiento y Gestión de las Enseñanzas Universitarias\n" \
          "SECRETARÍA GENERAL DE UNIVERSIDADES\nMINISTERIO DE UNIVERSIDADES\n" \
          "Paseo de la Castellana 162, planta 17\n28071 MADRID",
      teaching_authority_website:
        "https://www.universidades.gob.es/stfls/universidades/ministerio/ficheros/BREXIT/solicitud-certificado-reino-unido.pdf"
    },
    # Canada (British Columbia)
    {
      country_code: :CA,
      name: "British Columbia",
      sanction_check: :online,
      status_check: :online
    },
    # Cyprus
    { country_code: :CY, sanction_check: :none, status_check: :none }
  ]

  def self.private_beta!
    Region.where(legacy: false).update_all(legacy: true)

    PRIVATE_BETA_REGIONS.each do |region_attributes|
      country_code = region_attributes.fetch(:country_code)
      name = region_attributes.fetch(:name, "")

      region =
        Region.joins(:country).find_by!(country: { code: country_code }, name:)

      region.update!(
        region_attributes.except(:country_code, :name).merge(legacy: false)
      )
    end
  end
end
