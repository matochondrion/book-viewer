require "sinatra"
require "sinatra/reloader"

get "/" do
  @title = 'test title'
  erb :home
end
