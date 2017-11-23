ActiveRecord::Migration.say_with_time("Loading region seeds") do
  regions = [
    "Africa",
    "Annex-1",
    "Asia",
    "Central Asia",
    "East Asia and Pacific",
    "Europe",
    "G20",
    "Latin America and Caribbean",
    "Middle East",
    "Middle East and North Africa",
    "North America",
    "OECD",
    "South America",
    "South Asia",
    "Southeast Asia",
    "Australia/New Zealand",
    "European Union",
    "Mexico/Chile",
    "World",
    "Africa_Northern",
    "Africa_Eastern",
    "Africa_Southern",
    "Africa_Western",
    "Central America and Caribbean",
    "EU-12",
    "EU-15",
    "Europe_Eastern",
    "Europe_Non_EU",
    "European Free Trade Association",
    "South America_Northern",
    "South America_Southern"
  ]

  regions.each { |region| Location.create(name: region, region: true) }
end
