module ApplicationHelper
  def sidebar_permission?(page)
    current_user.allowed_permissions.include?(page)
  end

  def country_codes_for_select
    ISO3166::Country.all.map do |country|
      name = country.translations['en'] || country.iso_short_name
      ["#{name} (+#{country.country_code})", country.country_code]
    end
  end
end
