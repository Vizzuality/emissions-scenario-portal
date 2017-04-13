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
    name: 'GCAM. Global Change Assessment Model'
  },
  {
    name: 'EPS. Energy Policy Solutions Model'
  },
  {
    name: 'E3 Pathways Model'
  }
].each { |model_attrs| Model.create(model_attrs.merge(team: @team_amazing))}
