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

# Calls the block for each chapter, passing that chapter's number, name, and
# # contents.
def each_chapter
  @contents.each.with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

# This method returns an Array of Hashes representing chapters that match the
# specified query. Each Hash contain values for its :name and :number keys.
def chapters_matching(query)
  results = []

  return results if !query || query.empty?

  each_chapter do |number, name, contents|
    results << {number: number, name: name} if contents.include?(query)
  end

  results
end

not_found do
  redirect ('/')
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

  redirect "/" unless (1..@contents.size).cover? number

  @title = "Chapter #{number}: #{chapter_name}"
  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

get '/show/:name' do
  params[:name]
end

get '/search' do
  @results = chapters_matching(params[:query])
  erb :search
end

