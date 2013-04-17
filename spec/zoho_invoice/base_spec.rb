require 'spec_helper'

describe ZohoInvoice::Base do

  before do
    @client = ZohoInvoice::Client.new(default_credentials)
  end

  it "requires a client upon initialization" do
    expect{ ZohoInvoice::Base.new }.to raise_error(StandardError)
  end

  it "can define the attributes of an instance object and assign them on initialization" do
    class TestClass < ZohoInvoice::Base
      define_object_attrs :test_it
    end

    test_obj = TestClass.new(@client)
    expect(test_obj.respond_to?('test_it')).to be_true
    expect(test_obj.respond_to?('test_it=')).to be_true
    expect(test_obj.attributes).to eq([:test_it])

    test_obj1 = TestClass.new(@client, :test_it => 1)
    expect(test_obj1.test_it).to eq(1)
  end

  it "can define associations to itself" do
    class TestClass < ZohoInvoice::Base
      has_many :things,
        :more_things
    end

    test_obj = TestClass.new(@client)
    expect(test_obj.things.is_a?(Array)).to be_true
    expect(test_obj.things.length).to eq(0)
    expect(test_obj.reflections).to eq([:things, :more_things])
  end

  describe "generating an xml representation" do
    before do
      class ZohoInvoice::Something < ZohoInvoice::Base
        define_object_attrs :test_it,
          :blah,
          :something_id

        has_many :things,
          :more_things
      end

      @test_obj = ZohoInvoice::Something.new(@client)
    end

    it "should specific an xml doctype" do
      xml = @test_obj.to_xml
      expect(xml).to include("<?xml version=\"1.0\"?>")
    end

    it "should have a root element" do
      xml = Nokogiri::XML(@test_obj.to_xml)
      expect(xml.children.length).to eq(1)
      expect(xml.children.first.name).to eq("Something")

      @test_obj.test_it = 1234
      xml = Nokogiri::XML(@test_obj.to_xml)
      expect(xml.children.length).to eq(1)
      expect(xml.children.first.name).to eq("Something")
    end

    it "should create the attributes correctly" do
      @test_obj.test_it = 1234
      xml = Nokogiri::XML(@test_obj.to_xml)
      expect(xml.xpath('//TestIt').length).to eq(1)
      expect(xml.xpath('//TestIt').first.text).to eq('1234')

      @test_obj.test_it = nil
      xml = Nokogiri::XML(@test_obj.to_xml)
      expect(xml.xpath('//TestIt')).to be_empty
    end

    it "should create the associations correctly" do
      class Thing < Struct.new(:stuff)
        def to_xml(*args)
          "<Thing>#{stuff}</Thing>"
        end
      end
      @test_obj.things << Thing.new('asdf')
      @test_obj.things << Thing.new('asdf')

      @test_obj.more_things << Thing.new('1234')

      xml = Nokogiri::XML(@test_obj.to_xml)
      expect(xml.xpath('//Things').length).to eq(1)
      expect(xml.xpath('//Things/Thing').length).to eq(2)
      expect(xml.xpath('//MoreThings/Thing').length).to eq(1)
    end
  end

  describe "interactions" do
    before do
      class Something < ZohoInvoice::Base
        define_object_attrs :something_id, :blah
      end
      @test_obj = Something.new(@client)
    end

    describe "saving" do
      it "calls the create path if its a new record" do
        @test_obj.something_id = nil
        body_params = default_credentials.merge(:XMLString => @test_obj.to_xml)
        stub_post('/api/somethings/create').
          with(:body => body_params).
          to_return(:status => 200, :body => successful_something_response('5555'), :headers => {:content_type => 'application/xml'})
        @test_obj.save
        expect(a_post('/api/somethings/create').with(:body => body_params)).to have_been_made
      end

      it "calls the update path if its a dirty record" do
        @test_obj.something_id = '123456'
        body_params = default_credentials.merge(:XMLString => @test_obj.to_xml)
        stub_post('/api/somethings/update').
          with(:body => body_params).
          to_return(:status => 200, :body => successful_something_response('123456'), :headers => {:content_type => 'application/xml'})
        @test_obj.save
        expect(a_post('/api/somethings/update').with(:body => body_params)).to have_been_made
      end

      it "can happen via .create" do
        @test_obj.blah = '1234'
        body_params = default_credentials.merge(:XMLString => @test_obj.to_xml)
        stub_post('/api/somethings/create').
          with(:body => body_params).
          to_return(:status => 200, :body => successful_something_response("1234"), :headers => { :content_type => 'application/xml' })
        test_obj = Something.create(@client, :blah => '1234')
        expect(a_post('/api/somethings/create').with(:body => body_params)).to have_been_made
        expect(test_obj.something_id).to eq('1')
      end

      it "returns the object and has an error method" do
        @test_obj.blah = '1234'
        body_params = default_credentials.merge(:XMLString => @test_obj.to_xml)
        stub_post('/api/somethings/create').with(:body => body_params).to_return(:status => 500, :body => fixture('500_internal_server_error'), :headers => { :content_type => 'application/xml' })
        test_obj = Something.create(@client, :blah => '1234')
        expect(test_obj.something_id).to be_nil
        expect(test_obj.errors.length).to eq(1)
        error = test_obj.errors.first
        expect(error.message).to eq("Invalid value passed for XMLString")
        expect(error.code).to eq('2')
        expect(error.status).to eq('0')
        expect(error.http_status).to eq(500)
      end
    end

    describe "searching" do

      it "returns an array if it finds a single record" do
        body_params = default_credentials.merge(:searchtext => '1234')
        stub_get('/api/view/search/somethings').
          with(:query => body_params).
          to_return(:status => 200, :body => successful_single_record_response('1234'), :headers => {:content_type => 'application/xml'})
        result = Something.search(@client, '1234')
        expect(a_get('/api/view/search/somethings').with(query: body_params)).to have_been_made
        expect(result.class).to eq(Array)
        expect(result.length).to eq(1)
        result.each_with_index do |r, i|
          expect(r.class).to eq(Something)
          expect(r.something_id).to eq((i+1).to_s)
          expect(r.blah).to eq('1234')
        end
      end

      it "returns an array if it finds multiple records" do
        body_params = default_credentials.merge(:searchtext => '1234')
        stub_get('/api/view/search/somethings').
          with(:query => body_params).
          to_return(:status => 200, :body => successful_multiple_record_response('1234'), :headers => {:content_type => 'application/xml'})
        result = Something.search(@client, '1234')
        expect(a_get('/api/view/search/somethings').with(query: body_params)).to have_been_made
        expect(result.class).to eq(Array)
        expect(result.length).to eq(2)
        result.each_with_index do |r, i|
          expect(r.class).to eq(Something)
          expect(r.something_id).to eq((i+1).to_s)
          expect(r.blah).to eq('1234')
        end
      end

      it "returns an empty array if it cant find anything" do
        body_params = default_credentials.merge(:searchtext => '1234')
        stub_get('/api/view/search/somethings').
          with(:query => body_params).
          to_return(:status => 200, :body => successful_empty_response, :headers => {:content_type => 'application/xml'})
        result = Something.search(@client, '1234')
        expect(a_get('/api/view/search/somethings').with(query: body_params)).to have_been_made
        expect(result.class).to eq(Array)
        expect(result.length).to eq(0)
      end

      # TODO Needs to change because you'll have no idea an error happened
      #
      it "should return an empty array if theres an error" do
        body_params = default_credentials.merge(:searchtext => '1234')
        stub_get('/api/view/search/somethings').
          with(:query => body_params).
          to_return(:status => 500)
        result = Something.search(@client, '1234')
        expect(a_get('/api/view/search/somethings').with(query: body_params)).to have_been_made
        expect(result.class).to eq(Array)
        expect(result.length).to eq(0)
      end
    end

    def successful_something_response(blah_payload)
      "<Something><SomethingID>1</SomethingID><Blah>#{blah_payload}</Blah></Something>"
    end

    def successful_single_record_response(payload)
      "<Response><Somethings uri='/api/views/search/somethings'><Something><SomethingID>1</SomethingID><Blah>#{payload}</Blah></Something></Somethings></Response>"
    end

    def successful_multiple_record_response(payload)
      "<Response><Somethings uri='/api/views/search/somethings'><Something><SomethingID>1</SomethingID><Blah>#{payload}</Blah></Something><Something><SomethingID>2</SomethingID><Blah>#{payload}</Blah></Something></Somethings></Response>"
    end

    def successful_empty_response
      "<Response><Somethings uri='/api/views/search/somethings'></Somethings></Response>"
    end
  end

  describe "nested associations" do
    class ZohoInvoice::Tuna < ZohoInvoice::Base
      define_object_attrs :blah
    end
    class ZohoInvoice::TestIt < ZohoInvoice::Base
      has_many :tunas
    end

    before do
      @client = ZohoInvoice::Client.new(default_credentials)
    end

    it "can be created at initialization" do
      test = ZohoInvoice::TestIt.new(@client, :tunas => [{:blah => 1234}, ZohoInvoice::Tuna.new(@client, :blah => 5678)])
      expect(test.tunas.length).to eq(2)
      expect(test.tunas.first.blah).to eq(1234)
      expect(test.tunas.last.blah).to eq(5678)
    end

    it "outputted when coverted to xml", :focus => true do
      test = ZohoInvoice::TestIt.new(@client, :tunas => [{:blah => 1234}])
      doc  = Nokogiri::XML(test.to_xml)
      expect(doc.xpath('//Tunas').length).to be >= 1
      expect(doc.xpath('//Tuna').length).to eq(1)
    end
  end
end
