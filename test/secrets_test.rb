#!/usr/bin/env ruby

require 'maxitest/autorun'
require 'webmock/minitest'
require_relative "../lib/secrets.rb"

PEMFILE =<<ENDPEM
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAr3ZIyMNctQV9rhHgjgQcr43tIY6AwMue+eMynMbQXr0dDveR
RJ40Idf47QHBT87MJXbaEWpehPik737MfYa+ZpfhHXeE6LEoh3mK42Zpglfpgk3y
flMeziBIMD7t05XLmhuDdUXQ5r0wXUVta0Tj37OBfzM7BwQYbl1+O/lvXBPXUiGI
OXUgsPWt97eDQyRaNe4wmT0tFJ9Uj4iU0u9gWf6La1oykmkjlFPdlOESf+VpTCTF
dE4XT0AcKl0vIFvptXMT9uAG9W2pN10Ct9WZ17MmXsnmUPLMGQuvegIWXZ6bfQC9
/MjS6ihxWndixJQilWnZkCynTz6xiZzZNnyT4QIDAQABAoIBAQCVmh64vome9o2Q
C0IRFER5EmOrBtuUhoiHu0V+Eq26+Td7eW3suY7thD2DpslyCHpbPxjzXGQ2r+HB
KbWlGWviAYE5JJy34cUSrXjUJo+zSM2aAmfNeYV8bl3edOlGTCQKw4a0SNCyy4Af
JoECwvwf0eeJ0t5zPvSttR1aeXSPZhmeMzsqYySZtNq1v8wTEk2DGYHCAnaAL6Rq
pNK3UEYzIsWNOb7TqHqK6pDtopSNgSywHQs4WtmCiS82YxiqqUPqoCZOt1bfZd18
a5zMaYtE/H26h+TE9kuDLTeFtq/Y9jGTexps3VootQyXyOeVWQ4RY7T1ZYlnktaS
UmbwM0eZAoGBAN2NopxkdLe7s5POOYLP5/9LtiyhTOW1jz+Dbt/fJNatydnffSYv
l9UT8v9MhnPkkcC9RiRk7nVJ+RJMPEalvAOw6j2waZmY1wZL5LlVIbCxE8am+rkF
3A1N29yQ3YP94QuuqhBkoYuc/kFg0SzuPDH+e8njwnsLv6ZrOK3KPsofAoGBAMq+
Gvw536hVV49CmJMiPBY0pyNj2RzjuLGTC3PSho1JGKlMwNFHhlXmDZjo9k3dFJcB
YO1vVeAHOdq6GVNdSRsLH033FjN+vnjoLz6HCnuGQ+E/gypWxpY2yE7s2lPUh5Jr
PVWMiTcXlZHW5aEKhdkjzy5RbPkaQNh2Gjz8NOH/AoGAZb0XsjeTPZgtU698y2xL
vfl3k7ESjd29BU6GyLlAwnCV4730S2fJkmiRytjKWUfaAqcoIahTtHqerN9jQpHy
78L7Hg73vzfnbhXF17GXQfte+HdPZU2iil15nCTOBEG+aU3w/IwpfuI+A6nBBJ/1
9oNFNyWm9jgj7vkH0w6vnMMCgYEApZxQssQbnIfJ9G4z78xBROpRtSj0yxKBZhx1
eHD6FCMnj/PwdYN1imlXphZ2S/hRv2AS6yDNBykf6zmlQmGrO/oD4k35xqq7sEwJ
e4wX1ftBK5gT7tvfcAjj6wSy+1NaQxJykZUw6N3NAcqG3NuZplwH+w/scjctzSP8
HuDt2cUCgYAKGN18x95Vjk8bubWmnTyjn0Ben4YHXo599a2jRCQgNXiWi+sLFLtM
adoV5R2LrlXeTzb6obbWRUMuJ8Q9nmlO5Q5Bb2QdRa81SNbP7jzMKPx2RJcgOdmO
GOk9+6SGJ6ojZNhUtNzAEGzsCKVUwbsJNVieokjZbqyhd6XQGpZbWw==
-----END RSA PRIVATE KEY-----
-----BEGIN CERTIFICATE-----
MIIDgjCCAmoCCQDawA27wp+tsDANBgkqhkiG9w0BAQsFADCBgjELMAkGA1UEBhMC
VVMxEzARBgNVBAgMCkNhbGlmb3JuaWExCzAJBgNVBAcMAlNGMQwwCgYDVQQKDAN6
ZW4xDjAMBgNVBAsMBWluZnJhMRIwEAYDVQQDDAlsb2NhbGhvc3QxHzAdBgkqhkiG
9w0BCQEWEGl3YXRlcnNAemVuZC5jb20wHhcNMTYwNDI2MTg1NTA0WhcNMTYwNTI2
MTg1NTA0WjCBgjELMAkGA1UEBhMCVVMxEzARBgNVBAgMCkNhbGlmb3JuaWExCzAJ
BgNVBAcMAlNGMQwwCgYDVQQKDAN6ZW4xDjAMBgNVBAsMBWluZnJhMRIwEAYDVQQD
DAlsb2NhbGhvc3QxHzAdBgkqhkiG9w0BCQEWEGl3YXRlcnNAemVuZC5jb20wggEi
MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCvdkjIw1y1BX2uEeCOBByvje0h
joDAy5754zKcxtBevR0O95FEnjQh1/jtAcFPzswldtoRal6E+KTvfsx9hr5ml+Ed
d4TosSiHeYrjZmmCV+mCTfJ+Ux7OIEgwPu3TlcuaG4N1RdDmvTBdRW1rROPfs4F/
MzsHBBhuXX47+W9cE9dSIYg5dSCw9a33t4NDJFo17jCZPS0Un1SPiJTS72BZ/otr
WjKSaSOUU92U4RJ/5WlMJMV0ThdPQBwqXS8gW+m1cxP24Ab1bak3XQK31ZnXsyZe
yeZQ8swZC696AhZdnpt9AL38yNLqKHFad2LElCKVadmQLKdPPrGJnNk2fJPhAgMB
AAEwDQYJKoZIhvcNAQELBQADggEBAAJBoQkhb6ePl4PYRa1UArCDxIqeDm3JwXxh
mtLXRFZAzgKXeIys9jTsK7mEq1tUC60JYxks4B+NgMlzoYJc/s/OYj7g4PU+OnqC
jVbRwtMRIyJHY/P7SfBJJdmASiP/RKkF54AqxtsvrCTahyt93VRxeBxmOsIzS0o7
W7UlgQA3C72D8fSMdfAI/x53gH/+8Z/JKS4NIxXtzIwpgyAqA5w9gKVykA7wamHb
LYHB2Fw/YG29RN44NR6P9IWhsRRRPfChGp9rwMq3nPu2alSOGsrsYw5YN27tZ4CF
9UQ8+cDy9C2Fdub6F9DdQSaCtvJC5uyBui083vyn80w9r8oXR7A=
-----END CERTIFICATE-----
ENDPEM
ANNOTATION = "secret/this/is/my/SECRET"
BAD_ANNOTATION = "secret/this/is/my/SECRET\n"
ENV['NOLOG'] = 'true'

describe SecretsClient do

  let(:client) { SecretsClient.send(:vault_client).logical }
  before do
    # disalbe logging for tests
    #create a tmp pem file
    File.open('/tmp/vaultpem', 'w') { |f| f.write PEMFILE }
    File.open('/tmp/annotations', 'w') { |f| f.write ANNOTATION }
    File.open('/tmp/bad_annotations', 'w') { |f| f.write BAD_ANNOTATION }
    File.open('/tmp/fail_annotations', 'w') { |f| f.write "secret/this/is/my/SECRETFAIL" }
    auth_body = {auth: {client_token: 'sometoken'}}
    stub_request(:post, "https://foo.bar:8200/v1/auth/cert/login").
      to_return(body: auth_body.to_json)
    query_body = {data:{vault:'foo'}}
    stub_request(:get, 'https://foo.bar:8200/v1/secret%2Fsecret%2Fthis%2Fis%2Fmy%252FSECRET').
      to_return(body: query_body.to_json, headers: {'Content-Type': 'application/json'})
    bad_body = {foo:{bar:'fail'}}
    stub_request(:get, 'https://foo.bar:8200/v1/secret%2Fsecret%2Fthis%2Fis%2Fmy%252FSECRETFAIL').
      to_return(body: bad_body.to_json, headers: {'Content-Type': 'application/json'})
  end

  after do
    File.delete('/tmp/vaultpem')
    File.delete('/tmp/annotations')
    File.delete('/tmp/bad_annotations')
  end

  describe "vault authentication" do
    before do
      stub_request(:post, "https://foo.bar:8200/v1/auth/cert/login").to_return(status: 403)
    end

    it "fails" do
      assert_raises RuntimeError do
        SecretsClient.new('https://foo.bar:8200', '/tmp/vaultpem', false, '/tmp/annotations')
      end
    end
  end

  describe "invalid client" do
    it "missing pem" do
      assert_raises RuntimeError do
        SecretsClient.new('https://foo.bar:8200', '/tmp/foopy', false, '/tmp/annotations')
      end
    end

    it "missing annotations" do
      assert_raises RuntimeError do
        SecretsClient.new('https://foo.bar:8200', '/tmp/vaultpem', false, '/tmp/missing')
      end
    end
  end

  describe "valid client" do
    it "initializes" do
      assert SecretsClient.new('https://foo.bar:8200', '/tmp/vaultpem', false, '/tmp/annotations')
    end

    it '.process' do
      client =  SecretsClient.new('https://foo.bar:8200', '/tmp/vaultpem', false, '/tmp/annotations', '/tmp/')
      client.process
      File.read('/tmp/SECRET').must_equal("foo")
    end

    it 'succeedes when secret has newline in key name' do
      client =  SecretsClient.new('https://foo.bar:8200', '/tmp/vaultpem', false, '/tmp/bad_annotations', '/tmp/')
      client.process
      File.read('/tmp/SECRET').must_equal("foo")
    end

    it 'does not leave an RS in written secret' do
      client =  SecretsClient.new('https://foo.bar:8200', '/tmp/vaultpem', false, '/tmp/bad_annotations', '/tmp/')
      client.process
      refute_match(/.*\n/, File.read('/tmp/SECRET'))
    end

    it "raises when response is invalid" do
      client =  SecretsClient.new('https://foo.bar:8200', '/tmp/vaultpem', false, '/tmp/fail_annotations', '/tmp/')
      assert_raises(RuntimeError) do
        client.process.must_raise
      end
    end
  end
end
