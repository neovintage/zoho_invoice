module ZohoInvoice
  module AuthToken
    class AuthTokenResult < Struct.new(:authtoken, :cause)
      def success?
        return true if !authtoken.nil?
        false
      end
    end

    def self.generate_authtoken(email_id, password)
      client = ZohoInvoice::Client.new(:client_options => {:url => 'https://accounts.zoho.com'})
      response = client.request(
        :get,
        '/apiauthtoken/nb/create',
        {
          :SCOPE => ZohoInvoice.scope,
          :EMAIL_ID => email_id,
          :PASSWORD => password
        }
      )

      result = ZohoInvoice::AuthToken::AuthTokenResult.new(nil, nil)
      result.cause = response.body.match(/\nCAUSE=(.+)\n/)[1] if response.body =~ /RESULT=FALSE/
      result.authtoken = response.body.match(/AUTHTOKEN=(.+)\n/)[1] if response.body =~ /RESULT=TRUE/
      result
    end
  end
end
