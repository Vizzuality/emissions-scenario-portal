namespace :import do
  task locations: :environment do
    [
      {name: 'Argentina', iso_code2: 'AR', region: false},
      {name: 'Australia_NZ', iso_code2: nil, region: true},
      {name: 'Brazil', iso_code2: 'BR', region: false},
      {name: 'Canada', iso_code2: 'CA', region: false},
      {name: 'China', iso_code2: 'CN', region: false},
      {name: 'Colombia', iso_code2: 'CO', region: false},
      {name: 'EU-12', iso_code2: nil, region: true},
      {name: 'EU-15', iso_code2: nil, region: true},
      {name: 'India', iso_code2: 'IN', region: false},
      {name: 'Indonesia', iso_code2: 'ID', region: false},
      {name: 'Ireland', iso_code2: 'IE', region: false},
      {name: 'Japan', iso_code2: 'JP', region: false},
      {name: 'Mexico', iso_code2: 'MX', region: false},
      {name: 'Pakistan', iso_code2: 'PK', region: false},
      {name: 'Portugal', iso_code2: 'PT', region: false},
      {name: 'Russia', iso_code2: 'RU', region: false},
      {name: 'South Africa', iso_code2: 'ZA', region: false},
      {name: 'South Korea', iso_code2: 'KR', region: false},
      {name: 'Switzerland', iso_code2: 'CH', region: false},
      {name: 'Taiwan', iso_code2: 'TW', region: false},
      {name: 'United Kingdom', iso_code2: 'GB', region: false},
      {name: 'USA', iso_code2: 'US', region: false},
      {name: 'World', iso_code2: nil, region: true}
    ].each do |location_attrs|
      Location.create(location_attrs)
    end
  end
end

namespace :clear do
  task locations: :environment do
    Location.delete_all
  end
end

namespace :reimport do
  task locations: ['clear:locations', 'import:locations']
end
