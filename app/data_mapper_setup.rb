require './models/link' # this needs to be done after datamapper is initialised
require './models/tag'
require './models/user'

env = ENV['RACK_ENV'] || 'development'

# we're telling datamapper to use a postgres database on localhost. bookmark_manager_test/development
DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")


# After declaring your modesl, you should finalise them
DataMapper.finalize

# However, the database tables don't exist yet. Let's tell datamapper to create them
# DataMapper.auto_upgrade!
