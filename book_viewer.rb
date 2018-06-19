require "sinatra"
require "sinatra/reloader"

get "/" do
  @title = 'The Adventures of Shirlock Holmes'
  @contents = File.readlines('data/toc.txt')

  erb :home
end
