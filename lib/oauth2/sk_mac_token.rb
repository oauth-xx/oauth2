module OAuth2
  class SkMACToken < MACToken

    def header(request_line, host)
      kid = params['kid']
      timestamp = Time.now.utc.to_i
      nonce = Digest::MD5.hexdigest([timestamp, SecureRandom.hex].join(':'))
      access_token = token
      hmac_signature = signature(request_line, host, timestamp, nonce)

      "Authorization: MAC kid=\"#{kid}\" ts=\"#{timestamp}\" nonce=\"#{nonce}\" "\
      "access_token=\"#{access_token}\" mac=\"#{hmac_signature}\""
    end

    def signature(request_line, host, timestamp, nonce)
      sk_auth_str = "#{request_line}\n#{host}\n#{timestamp}\n#{nonce}\n"
      hmac_instance = OpenSSL::HMAC.new(secret, algorithm)
      hmac_signature = hmac_instance << sk_auth_str
      hmac_signature.to_s
    end
  end
end
