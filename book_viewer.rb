require "sinatra"
require "sinatra/reloader"

before do
  @contents = File.readlines('data/toc.txt')
end

helpers do
  def in_paragraphs(text)
    result = text.split("\n\n").map do |paragraph|
      "<p>#{paragraph}</p>"
    end

    result.join("\n")
  end
end

get "/" do
  @title = 'The Adventures of Shirlock Holmes'

  erb :home
end

get '/list' do
  @title = 'List'
  @files = Dir.glob('public/*.*').map { |file| File.basename(file) }.sort

  @files.reverse! if params[:sort] == 'desc'

  erb :list
end

get '/chapters/:number' do
  number = params[:number].to_i
  chapter_name = @contents[number - 1]
  @title = "Chapter #{number}: #{chapter_name}"
  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

get '/show/:name' do
  params[:name]
end
