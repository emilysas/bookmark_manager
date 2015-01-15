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
    # we initialize the object without saving it - can be invalid
    @user = User.new(:email => params[:email],
                :password => params[:password],
                :password_confirmation => params[:password_confirmation])
    # we try saving it
    # if valid, it will be saved
    if @user.save
      session[:user_id] = @user.id
      redirect to('/')
    # if it's not valid, we'll show the same form again
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
    # avoid having to memorise ascii codes
    user.password_token = (1..64).map{('A'..'Z').to_a.sample}.join
    user.password_token_timestamp = Time.now
    user.save
    # send an email with '/users/reset_password/user.password_token'
    redirect '/'
  end

  get '/sessions/request_token' do
    erb :"sessions/request_token"
  end

  get '/users/reset_password/:token' do
    # 1. find the user with a specific token
    user = User.first(:password_token => params[:token])
    @password_token = user.password_token
    # Check that the token was issued recently
    # we have to check if (Time.now - the time when the token was created) is greater than 5 min
    # 2. give a form to the user (new pass + conf)
    erb :"sessions/change_password"
  end

  post '/sessions/password_reset' do
    user = User.first(:password_token => params[:password_token])
    user.update(:password => params[:password], :password_confirmation => params[:password_confirmation])
  end

  delete '/sessions' do
    session.clear
    flash[:notice]="Good bye!"
    redirect '/'
  end

end