require "sinatra"
require "sinatra/reloader"

get "/" do
  # @title = 'The Adventures of Shirlock Holmes'
  # @contents = File.readlines('data/toc.txt')

  # erb :home
  @files = Dir.glob('public/*.*').map { |file| File.basename(file) }.sort
  @files.reverse! if params[:sort] == 'desc'

  erb :list
end

get '/chapters/1' do
  @title = 'Chapter 1'
  @chapter = File.read('data/chp1.txt')
  @contents = File.readlines('data/toc.txt')

  erb :chapter
end
