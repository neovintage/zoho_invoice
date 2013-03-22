require 'spec_helper'

describe ZohoInvoice::AuthToken do

  it "should be able to generate a new authtoken" do
    email_id = 'big_tuna@example.com'
    password = 'tuna'

    stub_request(:get, 'https://accounts.zoho.com/apiauthtoken/nb/create').
      with(:query => default_auth_options(email_id, password)).
      to_return(:body => fixture('successful_authtoken'))

    result = ZohoInvoice::AuthToken.generate_authtoken(email_id, password)
    expect(result.success?).to be_true
    expect(result).to be_a ZohoInvoice::AuthToken::AuthTokenResult
    expect(a_request(:get, 'https://accounts.zoho.com/apiauthtoken/nb/create')
      .with(:query => default_auth_options(email_id, password)))
      .to have_been_made
  end

  describe "failure cases" do

    it "should be unccessful if user name is incorrect" do
      bad_request('invalid_user', 'tuna@example.com', 'tuna') do |auth_token_result|
        expect(auth_token_result.cause).to eq('NO_SUCH_USER')
      end
    end

    it "should be unccessful if user name is incorrect" do
      bad_request('invalid_password', 'big_tuna@example.com', 'tu') do |auth_token_result|
        expect(auth_token_result.cause).to eq('INVALID_PASSWORD')
      end
    end

    def bad_request(fixture_to_use, email_id, password)
      stub_request(:get, 'https://accounts.zoho.com/apiauthtoken/nb/create').
        with(:query => default_auth_options(email_id, password)).
        to_return(:body => fixture(fixture_to_use))

      result = ZohoInvoice::AuthToken.generate_authtoken(email_id, password)
      expect(result.success?).to be_false
      expect(result).to be_a ZohoInvoice::AuthToken::AuthTokenResult
      expect(a_request(:get, 'https://accounts.zoho.com/apiauthtoken/nb/create')
        .with(:query => default_auth_options(email_id, password)))
        .to have_been_made

      yield result
    end

  end

  it "should define an auth token result" do
    result = ZohoInvoice::AuthToken::AuthTokenResult.new(nil, nil)
    expect(result.respond_to?(:authtoken)).to be_true
    expect(result.respond_to?(:cause)).to be_true

    expect(result.success?).to be_false

    result.authtoken = 'asdf'
    expect(result.success?).to be_true
  end

  private

  def default_auth_options(email, password)
    {
      :SCOPE => 'invoiceapi',
      :EMAIL_ID => email,
      :PASSWORD => password
    }
  end

end
