namespace :import do
  task locations: :environment do
    [
      {
        name: 'Poland',
        iso_code2: 'PL',
        region: false
      },
      {
        name: 'Portugal',
        iso_code2: 'PT',
        region: false
      },
      {
        name: 'Spain',
        iso_code2: 'ES',
        region: false
      },
      {
        name: 'United Kingdom',
        iso_code2: 'GB',
        region: false
      },
      {
        name: 'EU',
        iso_code2: nil,
        region: true
      }
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
