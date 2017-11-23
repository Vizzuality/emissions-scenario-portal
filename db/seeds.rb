load Rails.root.join('db', 'seeds', 'regions.rb')
load Rails.root.join('db', 'seeds', 'locations.rb')
load Rails.root.join("db", "seeds", "#{Rails.env}.rb")
