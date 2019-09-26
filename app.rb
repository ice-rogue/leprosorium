require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'database.db'
  @db.results_as_hash = true
end

before do
  init_db
end

configure do
  init_db
  @db.execute "CREATE TABLE IF NOT EXISTS 'Posts' (id INTEGER PRIMARY KEY AUTOINCREMENT, created_date DATE, content TEXT)"
  @db.execute "CREATE TABLE IF NOT EXISTS 'Comments' (id INTEGER PRIMARY KEY AUTOINCREMENT, created_date DATE, content TEXT, post_id integer)"
end

get '/' do 
  @results = @db.execute "SELECT * from Posts order by id desc"

  erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  content = params[:content]

  if content.empty?
    @error = 'Type text!'
    return erb :new
  end

  @db.execute "INSERT INTO Posts (content, created_date) values (?, datetime())", [content]

  redirect to '/'
  erb "You typed #{content}"
end

get '/details/:post_id' do 
  post_id = params[:post_id]

  results = @db.execute "SELECT * from Posts where id = ?", [post_id]
  @row = results[0]

  @comments = @db.execute "SELECT * from Comments where post_id = ? order by id", [post_id]

  erb :details
end

post '/details/:post_id' do
  post_id = params[:post_id]

  content = params[:content]

  @db.execute "INSERT INTO Comments (content, created_date, post_id) values (?, datetime(), ?)", [content, post_id]

  redirect to('/details/' + post_id)
end
