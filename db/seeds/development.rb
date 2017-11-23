ActiveRecord::Migration.say_with_time('Loading development seeds') do
  team_amazing = Team.create(name: 'Team Amazing')

  admin = User.new(
    name: 'Admin',
    email: 'adminamazing.com',
    admin: true,
    team: team_amazing
  )
  admin.save(validate: false)

  user = User.new(
    name: 'John Smart',
    email: 'john.smartamazing.com',
    team: team_amazing
  )
  user.save(validate: false)

  [
    {
      abbreviation: 'EPS',
      full_name: 'Energy Policy Solutions Model'
    },
    {
      abbreviation: 'E3',
      full_name: 'E3 Pathways Model'
    }
  ].each { |model_attrs| Model.create(model_attrs.merge(team: team_amazing)) }

  gcam = Model.create(
    abbreviation: 'GCAM',
    full_name: 'Global Change Assessment Model',
    current_version: '4',
    development_year: 2012,
    programming_language: ['Python'],
    maintainer_name: 'Pacific Northwest National Laboratory (PNNL)',
    license: 'Free and Open Source',
    team: team_amazing
  )

  [
    'GCAM-Reference', 'GCAM-Paris', 'GCAM-Paris Plus', 'RCP 2.6', 'RCP 6.0'
  ].each do |scenario_name|
    Scenario.create(name: scenario_name, model: gcam)
  end

  energy = Category.create(name: 'Energy')
  energy_use_by_fuel= Category.create(
    name: 'Energy use by fuel',
    parent: energy,
    stackable: true
  )

  [
    {
      category: energy,
      subcategory: energy_use_by_fuel,
      name: 'Biomass w CSS',
      definition: 'Bio-energy with carbon capture and storage (BECCS) is a future greenhouse gas mitigation technology which produces negative carbon dioxide emissions by combining bioenergy (energy from biomass) use with geologic carbon capture and storage.',
      unit: 'EJ/yr'
    },
    {
      category: energy,
      subcategory: energy_use_by_fuel,
      name: 'Biomass w/o CSS',
      definition: 'Bio-energy without carbon capture and storage (BECCS) is a future greenhouse gas mitigation technology which produces negative carbon dioxide emissions.',
      unit: 'EJ/yr'
    },
    {
      category: energy,
      subcategory: energy_use_by_fuel,
      name: 'Oil w CSS',
      definition: 'Carbon capture and storage (CCS) (or carbon capture and sequestration) is the process of capturing waste carbon dioxide (CO2).',
      unit: 'EJ/yr'
    },
    {
      category: energy,
      subcategory: energy_use_by_fuel,
      name: 'Oil w/o CSS',
      definition: 'An oil is any neutral, nonpolar chemical substance that is a viscous liquid at ambient temperatures...',
      unit: 'EJ/yr'
    }
  ].each do |indicator_attrs|
    Indicator.create(indicator_attrs)
  end
end
