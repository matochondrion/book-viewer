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
    result = {number: number, name: name} if contents.include?(query)
    next if !result
    result[:paragraphs] = paragraphs_matching(contents, query)
    results << result
  end

  results
end

=begin
- assign numerical paragraph ids to every paragraph in view
- for chapters that have matches:
  - search each paragraph based on \n\n and keep track of count
  - search each paragraph for include? query
  - on found, add result of par-id to result
  - add the result as an array to the original results hash like:
    - [ {number: number, name: name, paragraphs: [1, 3, 7]} ]
- display the results with each iterators in the view file (details later)
=end

def paragraphs_matching(contents, query)
  paragraphs = contents.split("\n\n")
  paragraphs = paragraphs.each.with_index.select do |paragraph, _|
    paragraph.include?(query)
  end
  paragraphs.map do |text, id|
    {text: text, id: "paragraph-#{id}"}
  end
end

get '/search' do
  @results = chapters_matching(params[:query])
  erb :search
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

