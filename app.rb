require_relative "shotgun"
require_relative "settings"

REDIRECT_URI  = "http://localhost:8080/oauth/callback"
SCOPE         = "GET IDENTITY"

AUTHORIZATION_ENDPOINT = "https://staging.m2x.sl.attcompute.com/oauth/authorize"
API_ENDPOINT           = "https://staging-api.m2x.sl.attcompute.com"
TOKEN_PATH             = "/oauth/token"

def api_request(verb, path, params = {}, headers = {})
  uri = URI.parse("#{API_ENDPOINT}#{TOKEN_PATH}")

  options = {}
  options.merge!(use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) if uri.scheme == "https"

  headers.merge!("Content-Type" => "application/json")

  body = JSON.dump(params)

  response = Net::HTTP.start(uri.host, uri.port, options) do |http|
    http.send_request(verb.to_s.upcase, path, body, headers)
  end

  JSON.parse(response.body)
end

Cuba.define do
  on root do
    res.write('<html><a href="/authorize">Authorize me!</a></html>')
  end

  on "authorize" do
    state = SecureRandom.hex(4)

    query = URI.encode_www_form(
      client_id: Settings::CLIENT_ID,
      redirect_uri: REDIRECT_URI,
      scope: SCOPE,
      response_type: "code",
      state: state)

    url = "#{AUTHORIZATION_ENDPOINT}/?#{query}"

    res.redirect(url)
  end

  on "oauth" do
    on "callback" do
      code = req.params["code"]

      params = {
        code:          code,
        client_id:     Settings::CLIENT_ID,
        client_secret: Settings::CLIENT_SECRET,
        grant_type:    "authorization_code",
        redirect_uri: REDIRECT_URI
      }

      json = api_request(:post, TOKEN_PATH, params)

      if json["access_token"]
        access_token = json["access_token"]

        headers = { "X-M2X-KEY" => access_token}

        response = api_request(:get, "/oauth/info", {}, headers)

        res.write("<html><h1>Success!</h1><p>Your access token is: #{access_token}</p><p>The response from the /info endpoint is: #{response.inspect}</p></html>")
      else
        res.write("Access token request failed: #{json.inspect}")
      end
    end
  end
end
