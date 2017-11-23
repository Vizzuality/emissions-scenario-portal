ActiveRecord::Migration.say_with_time('Loading location seeds') do
  CSV.foreach(
    Rails.root.join('db', 'seeds', 'locations.csv'),
    headers: :first_row
  ) do |row|
    Location.create(
      name: row['Country'],
      iso_code: row['ISO-2 Code'],
      region: false
    )
  end
end
