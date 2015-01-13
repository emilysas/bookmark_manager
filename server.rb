require 'data_mapper'
require 'sinatra'

env = ENV['RACK_ENV'] || 'development'

# we're telling datamapper to use a postgres database on localhost. bookmark_manager_test/development
DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

require './lib/link' # this needs to be done after datamapper is initialised
require './lib/tag'

# After declaring your modesl, you should finalise them
DataMapper.finalize

# However, the database tables don't exist yet. Let's tell datamapper to create them
DataMapper.auto_upgrade!

class BookmarkManager < Sinatra::Base

  get '/' do
    @links = Link.all
    erb :index
  end

  post '/links' do
    url = params["url"]
    title = params["title"]
    tags = params["tags"].split(" ").map {|tag| Tag.first_or_create(:text => tag)}
    Link.create(:url => url, :title => title, :tags => tags)
    redirect to('/')
  end

end