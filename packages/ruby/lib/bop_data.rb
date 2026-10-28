# frozen_string_literal: true
require 'json'
require 'net/http'
require 'uri'
module BopData
  class Error < StandardError
    attr_reader :kind, :status
    def initialize(kind, status = nil)
      @kind, @status = kind, status
      super(status ? "HTTP #{status}" : kind.to_s)
    end
  end
  class Client
    def initialize(base_url: 'https://data.bop.ink', timeout: 10)
      uri = URI.parse(base_url)
      raise ArgumentError, 'Invalid client configuration' unless %w[http https].include?(uri.scheme) && uri.host && !uri.userinfo && !uri.query && !uri.fragment && timeout.is_a?(Numeric) && timeout.positive?
      @base_url, @timeout = base_url.sub(%r{/+$}, ''), timeout
    end
    def list_datasets = request('/api/v1/datasets.json', 'bop.catalog/1')
    def get_dataset(id) = request("/api/v1/datasets/#{validate_id(id)}.json", 'bop.dataset/1')
    def get_dataset_csv(id) = request("/api/v1/datasets/#{validate_id(id)}.csv", nil)
    private
    def validate_id(id)
      raise Error.new(:invalid_id) unless id.is_a?(String) && /\A[A-Za-z0-9._-]{3,}\z/.match?(id)
      id
    end
    def request(path, spec)
      uri = URI.parse(@base_url + path)
      begin
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.open_timeout = @timeout
        http.read_timeout = @timeout
        response = http.request(Net::HTTP::Get.new(uri.request_uri, 'User-Agent' => 'BOPDataSDK/0.1'))
      rescue Net::OpenTimeout, Net::ReadTimeout, Timeout::Error
        raise Error.new(:timeout)
      rescue IOError, SystemCallError, SocketError, OpenSSL::SSL::SSLError
        raise Error.new(:transport)
      end
      raise Error.new(:http, response.code.to_i) unless response.is_a?(Net::HTTPSuccess)
      body = response.body.force_encoding(Encoding::UTF_8)
      return body unless spec
      begin
        obj = JSON.parse(body)
      rescue JSON::ParserError
        raise Error.new(:json)
      end
      raise Error.new(:spec) unless obj.is_a?(Hash) && obj['spec'] == spec
      obj
    end
  end
end
