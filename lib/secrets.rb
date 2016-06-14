require 'vault'

class SecretsClient
  ENCODINGS = {"/": "%2F"}.freeze
  CERT_AUTH_PATH =  '/v1/auth/cert/login'.freeze
  VAULT_SECRET_BACKEND = 'secret/'.freeze
  SAMSON_SECRET_NAMESPACE = 'apps/'.freeze
  KEY_PARTS = 4

  # auth against the server, set a token in the Vault obj
  def initialize(vault_address:, pemfile_path:, ssl_verify:, annotations:, serviceaccount_dir:, output_path:, api_url:)
    raise "vault address not found" if vault_address.nil?
    raise "pemfile not found" unless File.exist?(pemfile_path.to_s)
    raise "annotations file not found" unless File.exist?(annotations.to_s)
    raise "serviceaccount dir #{serviceaccount_dir} not found" unless Dir.exist?(serviceaccount_dir.to_s)
    raise "api_url is null" if api_url.nil?

    @annotations = annotations
    @output_path = output_path
    @serviceaccount_dir = serviceaccount_dir
    @api_url = api_url

    Vault.configure do |config|
      config.ssl_pem_file = pemfile_path
      config.ssl_verify = ssl_verify
      config.address = vault_address
      config.ssl_timeout  = 3
      config.open_timeout = 3
      config.read_timeout = 2
    end

    # fetch vault token by authenticating with given pem
    response = http_post(File.join(Vault.address, CERT_AUTH_PATH), ssl_verify: ssl_verify, pem: pemfile_path)
    Vault.token = JSON.parse(response).fetch("auth").fetch("client_token")

    @secret_keys = File.read(@annotations).split("\n").map do |line|
      next unless line.start_with?(VAULT_SECRET_BACKEND)
      key, path = line.split("=", 2)
      key = key.split("/", 2).last
      [key, path]
    end.compact
    raise "#{annotations} contains no secrets" if @secret_keys.empty?
  end

  def write_secrets
    @secret_keys.each do |key, path|
      contents = read(path)
      File.write("#{@output_path}/#{key}", contents)
      puts "Writing #{key} with contents from secret key #{path}"
    end
    # Write out the pod's status.hostIP as a secret
    File.write("#{@output_path}/HOST_IP", hostip)
    # notify primary container that it is now safe to read all secrets
    File.write("#{@output_path}/.done", Time.now.to_s)
  end

  private

  def http_post(url, ssl_verify:, pem:)
    pem_contents = File.read(pem)
    uri = URI.parse(url)
    http = Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: (uri.scheme == 'https'),
      verify_mode: (ssl_verify ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE),
      cert: OpenSSL::X509::Certificate.new(pem_contents),
      key: OpenSSL::PKey::RSA.new(pem_contents)
    )
    response = http.request(Net::HTTP::Post.new(uri.path))
    response.body
  end

  def hostip
    token = File.read(@serviceaccount_dir + '/token')
    namespace = File.read(@serviceaccount_dir + '/namespace')
    uri = URI.parse(@api_url + "/api/v1/namespaces/#{namespace}/pods")
    req = Net::HTTP::Get.new(uri.path)
    req.add_field("Authorization", "Bearer #{token}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.ca_file = "#{@serviceaccount_dir}/ca.crt"
    puts uri.host
    response = http.request(req)
    if response.code.to_i == 200
      api_response = JSON.parse(response.body, symbolize_names: true)
      api_response[:items][0][:status][:hostIP].to_s
    else
      raise "Could not get hostIP from api server #{uri.host}: #{api_response.inspect}"
    end
  end

  def read(key)
    key = normalize_key(key)
    result = Vault.logical.read(vault_path(key))
    if !result.respond_to?(:data) || !result.data || !result.data.is_a?(Hash)
      raise "Bad results returned from vault server for #{key}: #{result.inspect}"
    end
    result.data.fetch(:vault)
  end

  # keys could include slashes in last part, which we would then be unable to resulve
  # so we encode them
  def normalize_key(key)
    parts = key.split('/', KEY_PARTS)
    ENCODINGS.each { |k, v| parts.last.gsub!(k.to_s, v.to_s) }
    parts.join('/')
  end

  def vault_path(key)
    (VAULT_SECRET_BACKEND + SAMSON_SECRET_NAMESPACE + key).delete('"')
  end
end
