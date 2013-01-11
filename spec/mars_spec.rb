require 'spec_helper'

require './mars'
require 'rack/test'

describe MarsApp do
  include Rack::Test::Methods

  def app
    MarsApp
  end

  it "should clear the database before testing" do
    Topic.all.should be_empty
  end

  it "shows the index page" do
    get '/'
    last_response.should be_ok
    last_response.body.should include 'List of Topics'
  end


  it "list topics on the index page" do
    topic = Topic.create name: "Test", title: "Pears"
    get '/'
    last_response.should be_ok
    last_response.body.should include 'Pears'
  end

  it "should create a new topic" do
    post "/new", {
        :topic => {
            :title => "Apples",
            :name => "Red"
        }
    }
    last_response.status.should == 302

    Topic.all.count.should == 1
    topic = Topic.all.first
    topic.should be
    topic.title.should == "Apples"
    topic.name.should == "Red"
  end


  it "should not replace an existing topic or post a new one if titles are the same" do
    topic = Topic.create name: "Test", title: "Pears"

    post "/new", {
        :topic => {
            :title => "Pears",
            :name => "Red"
        }
    }
    last_response.status.should == 302

    Topic.all.count.should == 1

    topic.reload

    # Nothing should be changed
    topic.name.should == "Test"
  end

  it "should delete a topic" do
    topic = Topic.create name: "TestName", title: "TestTitle", url: "TestURL", description: "TestDescription"
    post "/delete/#{topic.id}"
    Topic.all.count.should == 0
  end

  it "should update an existing topic" do
    topic = Topic.create name: "TestName", title: "TestTitle", url: "TestURL", description: "TestDescription"
  end

  it "should export json" do
    topic = Topic.create name: "Chuck Norris", title: "God", url: "Impossible", description: "A living legend"
    get "/topics.json"
    last_response.body.should == "{\"topics\":[{\"_id\":\"#{topic.id}\",\"description\":\"A living legend\",\"name\":\"Chuck Norris\",\"title\":\"God\",\"url\":\"Impossible\"}]}"
  end

  it "should export csv" do
    topic = Topic.create name: "Chuck Norris", title: "God", url: "Impossible", description: "A living legend"
    get "topics.csv"
    last_response.body.should == "Name,Title,URL,Description\nChuck Norris,God,Impossible,A living legend\n"
  end

  it "should import csv" do
    post '/upload.csv', :data => Rack::Test::UploadedFile.new("test.csv", "application/octet-stream")
    last_response.status.should == 302
    Topic.all.count.should == 5

    # Test specifics
    topic = Topic.find_by(title: "Pear")
    topic.name.should == "Pears"
  end

end
