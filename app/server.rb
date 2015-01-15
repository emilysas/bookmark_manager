require 'sinatra'
require 'data_mapper'
require 'rack-flash'

require_relative 'helpers/application'
require_relative 'data_mapper_setup'

class BookmarkManager < Sinatra::Base

  enable :sessions
  set :session_secret, 'super secret'
  use Rack::Flash
  use Rack::MethodOverride

  helpers CurrentUser

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

  get '/tags/:text' do
    tag = Tag.first(:text => params[:text])
    @links = tag ? tag.links : []
    erb :index
  end

  get '/users/new' do
    @user = User.new
    erb :"users/new"
  end

  post '/users' do
    @user = User.new(:email => params[:email],
                :password => params[:password],
                :password_confirmation => params[:password_confirmation])
    if @user.save
      session[:user_id] = @user.id
      redirect to('/')
    else
      flash.now[:errors] = @user.errors.full_messages
      erb :"users/new"
    end
  end

  get '/sessions/new' do
    erb :"sessions/new"
  end

  post '/sessions' do
    email, password = params[:email], params[:password]
    user = User.authenticate(email, password)
    if user
      session[:user_id] = user.id
      redirect to ('/')
    else
      flash[:errors] = ["the email or password is incorrect"]
      erb :"sessions/new"
    end
  end

  post '/sessions/reminder' do
    user = User.first(:email => params[:email])
    user.password_token = (1..64).map{('A'..'Z').to_a.sample}.join
    user.save
    'check your email'
  end

  get '/sessions/request_token' do
    erb :"sessions/request_token"
  end

  get '/sessions/change_password/:token' do
    @password_token = params[:token]
    erb :'sessions/change_password'
  end

  post '/sessions/password_reset' do
    user = User.first(:password_token => params[:password_token])
    user.update(:password => params[:new_password], :password_confirmation => params[:password_confirmation])
    user.save
  end

  delete '/sessions' do
    session.clear
    flash[:notice]="Good bye!"
    redirect '/'
  end

end