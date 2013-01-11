require 'sinatra'
require 'active_support/all'
require 'sinatra/flash'
require './models'
require 'csv'


class MarsApp <Sinatra::Base
  register Sinatra::Flash

  set :public_folder, File.dirname(__FILE__) + '/static'
  set :run, false
  set :port, ENV['PORT'] || '4567'

  enable :sessions, :inline_templates
  enable :methodoverride

  get '/' do
    @t = Topic.all
    if @t.empty?
      flash[:notice] = "No documents found!"
    end
    erb :index
  end

  get '/new' do
    #t = Topic.new
    erb :new
  end

  post '/new' do
    existing = Topic.where(title: params[:topic][:title]).first
    if existing
      flash[:notice] = "Topic already exists!"
    else
      t = Topic.new(params[:topic])
      t.save!
    end
    redirect '/'
  end

  get '/show/:id' do |id|
    @t = Topic.find(id)
    erb :show
  end

  get '/edit/:id' do |id|
    @t = Topic.find(id)
    erb :edit
  end

  post '/update/:id' do
    @t = Topic.find(params[:id])
    @t.update_attributes(params[:topic])
    erb :show
  end

  post '/delete/:id' do
    t = Topic.find(params[:id])
    t.destroy
    redirect '/'
  end

  get '/topics.json' do
    topics = Topic.all
    content_type :json
    { topics: topics }.to_json
    #topics_hash = []
    #topics.each do |topic|
    #  topics_hash << {name: topic.name}
    #end
    #{ topics: topics_hash }.to_json
  end

  get '/topics.csv' do
    headers "Content-Disposition" => "attachment;filename=Topics.csv",
            "Content-Type" => "application/octet-stream"
    csv_string = CSV.generate do |csv|
      csv << ["Name", "Title", "URL", "Description"]
      Topic.each do |top|
        csv << [top.name, top.title, top.url, top.description]
      end
    end
  end

  post '/upload.csv' do
    datafile = params[:data]
    data = datafile[:tempfile].read

    amount = 0
    CSV.parse(data, headers: true).each do |row|
      existing = Topic.where(title: row['Title']).first
      if existing
        existing.name = row['Name']
        existing.url = row['URL']
        existing.description = row['Description']
        existing.save!
        amount += 1
      else
        t = Topic.new()
        t.name = row['Name']
        t.title = row['Title']
        t.url = row['URL']
        t.description = row['Description']
        t.save!
      end
    end
    flash[:notice] = "CSV file uploaded. " + amount.to_s + " topics were replaced"
    redirect "/"
  end

end
