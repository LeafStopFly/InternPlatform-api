# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'

require_relative '../app/controllers/app'
require_relative '../app/models/post'

def app
  Internship::Api
end

DATA = YAML.safe_load File.read('app/db/seeds/post_seeds.yml')

describe 'Test Internship Web API' do
  include Rack::Test::Methods

  before do
    # Wipe database before each test
    Dir.glob("#{Internship::STORE_DIR}/*.txt").each { |postname| FileUtils.rm(postname) }
  end

  it 'should find the root route' do
    get '/'
    _(last_response.status).must_equal 200
  end

  describe 'Handle posts' do
    it 'HAPPY: should be able to get list of all [posts]' do
      Internship::Post.new(DATA[0]).save
      Internship::Post.new(DATA[1]).save

      get 'api/v1/posts'
      result = JSON.parse last_response.body
      _(result['post_ids'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single post' do
      Internship::Post.new(DATA[1]).save
      id = Dir.glob("#{Internship::STORE_DIR}/*.txt").first.split(%r{[/.]})[5]

      get "/api/v1/posts/#{id}"
      result = JSON.parse last_response.body

      _(last_response.status).must_equal 200
      _(result['id']).must_equal id
    end

    it 'SAD: should return error if unknown document requested' do
      get '/api/v1/posts/foobar'

      _(last_response.status).must_equal 404
    end

    it 'HAPPY: should be able to create new posts' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post 'api/v1/posts', DATA[1].to_json, req_header

      _(last_response.status).must_equal 201
    end
  end
end
