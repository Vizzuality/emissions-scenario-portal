# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
@team_amazing = Team.create(name: 'Team Amazing')

@admin = User.create(
  name: 'Admin',
  email: 'admin@amazing.com',
  admin: true,
  team: @team_amazing
)

@user = User.create(
  name: 'John Smart',
  email: 'john.smart@amazing.com',
  team: @team_amazing
)

[
  {
    abbreviation: 'EPS',
    full_name: 'Energy Policy Solutions Model'
  },
  {
    abbreviation: 'E3',
    full_name: 'E3 Pathways Model'
  }
].each { |model_attrs| Model.create(model_attrs.merge(team: @team_amazing))}

@gcam = Model.create(
  abbreviation: 'GCAM',
  full_name: 'Global Change Assessment Model',
  current_version: '4',
  development_year: 2012,
  programming_language: ['Python'],
  maintainer_type: 'private',
  maintainer_name: 'Pacific Northwest National Laboratory (PNNL)',
  license: 'Free and Open Source',
  team: @team_amazing
)

[
  'GCAM-Reference', 'GCAM-Paris', 'GCAM-Paris Plus', 'RCP 2.6', 'RCP 6.0'
].each do |scenario_name|
  Scenario.create(name: scenario_name, model: @gcam)
end
