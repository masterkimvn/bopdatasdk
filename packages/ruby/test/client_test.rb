require 'minitest/autorun'
require 'socket'
require_relative '../lib/bop_data'
class ClientTest < Minitest::Test
  def setup
    @server = TCPServer.new('127.0.0.1', 0)
    @thread = Thread.new do
      loop do
        sock = @server.accept
        request = sock.gets
        next unless request
        while (line = sock.gets) && line != "\r\n"; end
        path = request.split[1]
        if path.include?('slow')
          sleep 0.2
          sock.close
          next
        end
        code = path[/status(404|429|503)/, 1]
        body = if code then ''
               elsif path.include?('invalid') then '{'
               elsif path.include?('wrong') then '{"spec":"wrong"}'
               elsif path.end_with?('.csv') then "\uFEFFa,b\r\n"
               else File.read(File.expand_path("../../../tests/fixtures/#{path.end_with?('datasets.json') ? 'catalog' : 'dataset'}.json", __dir__))
               end
        sock.write("HTTP/1.1 #{code || 200} OK\r\nContent-Length: #{body.bytesize}\r\nConnection: close\r\n\r\n#{body}")
        sock.close
      end
    rescue IOError, Errno::EBADF
    end
  end
  def teardown
    @server.close
    @thread.kill
    @thread.join
  end
  def test_contract
    c = BopData::Client.new(base_url: "http://127.0.0.1:#{@server.addr[1]}")
    assert_equal 2, c.list_datasets['total']
    d = c.get_dataset('test.one')
    assert_equal 'preserved', d['future']
    assert_nil d['freshness']['lastUpdated']
    assert_equal 'synthetic', d['provenance']['license']
    assert_equal "\uFEFFa,b\r\n", c.get_dataset_csv('test.one')
    ['', 'a/b', 'abc\n', 'đxx'].each { |id| assert_raises(BopData::Error) { c.get_dataset(id) } }
    [404, 429, 503].each { |code| assert_equal code, assert_raises(BopData::Error) { c.get_dataset("status#{code}") }.status }
    %w[invalid wrong].each { |id| assert_raises(BopData::Error) { c.get_dataset(id) } }
    slow = BopData::Client.new(base_url: "http://127.0.0.1:#{@server.addr[1]}", timeout: 0.02)
    assert_equal :timeout, assert_raises(BopData::Error) { slow.get_dataset('slow') }.kind
  end
end
