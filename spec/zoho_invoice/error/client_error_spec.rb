require 'spec_helper'

describe ZohoInvoice::Error::ClientError do
    before do
      @client = ZohoInvoice::Client.new(default_credentials)
    end

    it "should return a new error from a response" do
      test_error = ZohoInvoice::Error::ClientError.from_response({:status=>500,
                                                    :headers=>{"content-type"=>"application/xml"},
                                                    :body=> {"Response"=>
                                                      {"Code"=>"2",
                                                        "Message"=>"Invalid value passed for XMLString",
                                                        "status"=>"0"}}})
    end

    it "should be able to handle a reponse with no data" do
      test_error = ZohoInvoice::Error::ClientError.from_response({:status=>500,
                                                    :headers=>{"content-type"=>"application/xml"},
                                                    :body=> {"Response"=>
                                                      {"Code"=>nil,
                                                        "Message"=>nil,
                                                        "status"=>nil}}})
    end

    it "should be able to handle a reponse with no body" do
      test_error = ZohoInvoice::Error::ClientError.from_response({:status=>500,
                                                    :headers=>{"content-type"=>"application/xml"},
                                                    :body=> nil})
    end

end
