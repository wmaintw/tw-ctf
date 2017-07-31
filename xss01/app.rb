require 'sinatra'
require 'sinatra/json'
require "sinatra/cross_origin"

enable :sessions

get '/' do
  return_page(:login)
end

get '/login' do
  return_page(:login)
end

post '/login' do
  username = params[:username]
  password = params[:password]

  user_in_db = find_user(username, password)

  if user_in_db == nil or user_in_db.empty?
    return_page(:login, 'Login failed!')
  else
    session[:current_user] = user_in_db[0]
    redirect to(:profile)
  end
end

get '/profile' do
  if !is_logged_in?
    redirect to(:login)
  else
    erb :profile, :layout => :main, :locals => {:user => session[:current_user]}
  end
end

get '/profile/edit' do
  if !is_logged_in?
    redirect to(:login)
  else
    erb :profile_edit, :layout => :main, :locals => {:user => session[:current_user], :message => ''}
  end
end

post '/profile' do
  if !is_logged_in?
    redirect to(:login)
  else
    gender = params[:gender]
    age = params[:age]
    email = params[:email]

    if is_not_empty(gender) and is_num(age) and is_not_empty(email)
      modified_user = session[:current_user]
      modified_user[:gender] = gender
      modified_user[:age] = age
      modified_user[:email] = email
      session[:current_user] = modified_user

      puts session[:current_user]
    end

    redirect to(:profile)
  end
end

get '/logout' do
  session.clear
  redirect to(:login)
end

helpers do
  def return_page(page, message = '')
    erb page, :layout => :main, :locals => {:message => message}
  end

  def is_logged_in?
    current_user = session[:current_user]
    current_user != nil and !current_user.empty?
  end

  def get_default_users
    john = {:name => "John", :username => "john", :password => "john123", :gender => "Male", :age => 24, :email => "john@daq.com"}
    bob = {:name => "Bob", :username => "bob", :password => "bob123", :gender => "Male", :age => 27, :email => "bob@daq.com"}
    alice = {:name => "Alice", :username => "alice", :password => "alice123", :gender => "Female", :age => 26, :email => "alice@daq.com"}
    [john, bob, alice]
  end

  def find_user(username, password)
    users = get_default_users()
    users.select {|u| u[:username] == username && u[:password] == password}
  end

  def is_not_empty(param)
    params != nil && !param.empty?
  end

  def is_num(param)
    result = true
    begin
      Integer(param)
    rescue
      result = false
    end
    return result
  end
end
