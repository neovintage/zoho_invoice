module ZohoInvoice
  module AuthToken
    AuthTokenResult = Struct.new(:authtoken, :cause) do
      def success?
        return true if !authtoken.nil?
        false
      end
    end

    def self.generate_authtoken(email_id, password)
      response = Excon.post('https://accounts.zoho.com/apiauthtoken/nb/create',
                   :body => URI.encode_www_form({
                     :SCOPE => 'invoiceapi',
                     :EMAIL_ID => email_id,
                     :PASSWORD => password
                   }),
                   :headers => { "Content-Type" => "application/x-www-form-urlencoded" }
                 )

      result = ZohoInvoice::AuthToken::AuthTokenResult.new(nil, nil)
      result.cause = response.body.match(/\nCAUSE=(.+)\n/)[1] if response.body =~ /RESULT=FALSE/
      result.authtoken = response.body.match(/AUTHTOKEN=(.+)\n/)[1] if response.body =~ /RESULT=TRUE/
      result
    end
  end
end
