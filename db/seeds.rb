# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
@team_amazing = Team.create(name: 'Team Amazing')

@admin = User.new(
  name: 'Admin',
  email: 'admin@amazing.com',
  admin: true,
  team: @team_amazing
)
@admin.save(validate: false)

@user = User.new(
  name: 'John Smart',
  email: 'john.smart@amazing.com',
  team: @team_amazing
)
@user.save(validate: false)

[
  {
    abbreviation: 'EPS',
    full_name: 'Energy Policy Solutions Model'
  },
  {
    abbreviation: 'E3',
    full_name: 'E3 Pathways Model'
  }
].each { |model_attrs| Model.create(model_attrs.merge(team: @team_amazing)) }

@gcam = Model.create(
  abbreviation: 'GCAM',
  full_name: 'Global Change Assessment Model',
  current_version: '4',
  development_year: 2012,
  programming_language: ['Python'],
  maintainer_name: 'Pacific Northwest National Laboratory (PNNL)',
  license: 'Free and Open Source',
  team: @team_amazing
)

[
  'GCAM-Reference', 'GCAM-Paris', 'GCAM-Paris Plus', 'RCP 2.6', 'RCP 6.0'
].each do |scenario_name|
  Scenario.create(name: scenario_name, model: @gcam)
end

[
  {
    category: 'Energy',
    subcategory: 'Energy use by fuel',
    stackable_subcategory: true,
    name: 'Biomass w CSS',
    definition: 'Bio-energy with carbon capture and storage (BECCS) is a future greenhouse gas mitigation technology which produces negative carbon dioxide emissions by combining bioenergy (energy from biomass) use with geologic carbon capture and storage.',
    unit: 'EJ/yr'
  },
  {
    category: 'Energy',
    subcategory: 'Energy use by fuel',
    stackable_subcategory: true,
    name: 'Biomass w/o CSS',
    definition: 'Bio-energy without carbon capture and storage (BECCS) is a future greenhouse gas mitigation technology which produces negative carbon dioxide emissions.',
    unit: 'EJ/yr'
  },
  {
    category: 'Energy',
    subcategory: 'Energy use by fuel',
    stackable_subcategory: true,
    name: 'Oil w CSS',
    definition: 'Carbon capture and storage (CCS) (or carbon capture and sequestration) is the process of capturing waste carbon dioxide (CO2).',
    unit: 'EJ/yr'
  },
  {
    category: 'Energy',
    subcategory: 'Energy use by fuel',
    stackable_subcategory: true,
    name: 'Oil w/o CSS',
    definition: 'An oil is any neutral, nonpolar chemical substance that is a viscous liquid at ambient temperatures...',
    unit: 'EJ/yr'
  }
].each do |indicator_attrs|
  Indicator.create(indicator_attrs)
end

countries = 'Afghanistan; Albania; Algeria; American Samoa; Andorra; Angola; Anguilla; Antigua and Barbuda; Argentina; Armenia; Aruba; Australia; Austria; Azerbaijan; Bahamas; Bahrain; Bangladesh; Barbados; Belarus; Belgium; Belize; Benin; Bermuda; Bhutan; Bolivia; Bosnia and Herzegovina; Botswana; Brazil; Brunei Darussalam; Bulgaria; Burkina Faso; Burundi; Cambodia; Cameroon; Canada; Cape Verde; Cayman Islands; Central African Republic; Chad; Chile; China; Christmas Island; Cocos (Keeling) Islands; Colombia; Comoros; Demographic Republic of the Congo; Republic of Congo; Cook Islands; Costa Rica; Ivory Coast; Croatia; Cuba; Cyprus; Czech Republic; Denmark; Djibouti; Dominica; Dominican Republic; East Timor; Ecuador; Egypt; El Salvador; Equatorial Guineau; Eritrea; Estonia; Ethiopia; Falkland Islands; Faroe Islands; Fiji; Finland; France; French Guiana; French Polynesia; French Southern Territories; Gabon; Gambia; Georgia; Germany; Ghana; Gibraltar; Great Britain; Greece; Greenland; Grenada; Guadelouupe; Guam; Guatemala; Guinea; Guinea-Bissau; Guyana; Haiti; Holy See; Honduras; Hong Kong; Hungary; Iceland; India; Indonesia; Iran; Iraq; Ireland; Israel; Italy; Jamaica; Japan; Jordan; Kazakhstan; Kenya; Kiribati; North Korea; South Korea; Kosovo; Kuwait; Kyrgyzstan; Lao; Latvia; Lebanon; Lesotho; Liberia; Libya; Liechtenstein; Lithuania; Luxembourg; Macau; Macedonia; Madagascar; Malawi; Malaysia; Maldives; Mali; Malta; Marshall Islands; Martinique; Mauritania; Mauritius; Mayotte; Mexico; Micronesia; Moldova; Monaca; Mongolia; Montenegro; Montserrat; Morocco; Mozambique; Myanmar; Namibia; Nauru; Nepal; Netherlands; Netherlands Antilles; New Caledonia; New Zealand; Nicaragua; Niger; Nigeria; Niue; Northern Mariana Islands; Norway; Oman; Pakistan; Palau; Palestinian territories; Panama; Papua New Guinea; Paraguay; Peru; Phillippines; Pitcairn Island; Poland; Portugal; Puerto Rico; Qatar; Reunion Island; Romania; Russian Federation; Rwanda; Saint Kitts and Nevis; Saint Lucia; Saint Vincent and the Grenadines; Samoa; San Marino; Sao Tome and Principe; Saudi Arabia; Senegal; Serbia; Seychelles; Sierra Leone; Singapore; Slovakia; Slovenia; Solomon Islands; Somalia; South Africa; South Sudan; Spain; Sri Lanka; Sudan; Suriname; Swaziland; Sweden; Switzerland; Syria; Taiwan; Tajikistan; Tanzania; Thailand; Tibet; Timor-Leste; Togo; Tokelau; Tonga; Trinidad and Tobago; Tunisia; Turkey; Turkmenistan; Turks and Caicos Islands; Tuvalu; Uganda; Ukraine; United Arab Emirates; United Kingdom; United States; Uruguay; Uzbekistan; Vanuatu; Vatican City State; Venezuela; Vietnam; Virgin Islands (British); Virgin Islands (U.S.); Wallis and Futuna Islands; Western Sahara; Yemen; Zambia; Zimbabwe'.split('; ')
regions = 'Africa; Annex-1; Asia; Australia_NZ; Central Asia; East Asia and Pacific; Europe; G20; Latin America and Caribbean; Middle East; Middle East and North Africa; North America; OECD; Rest of World; South America; South Asia; Southeast Asia'.split('; ')
countries.each { |name| Location.create(name: name, region: false) }
regions.each { |name| Location.create(name: name, region: true) }
