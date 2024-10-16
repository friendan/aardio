require 'json'
require 'open3'

source_files = ENV['RUBY_SERVER_SOURCE']
unless (source_files||"").empty?
  source_files.split(':').each do |file|
    require_relative file
  end
end

def do_rpc(rpc)
  params = rpc[:params] 
  method = rpc[:method].to_sym

  begin   
    if params.is_a?(Array)
      result = send(method, *params) 
    elsif params.is_a?(Hash)
      result = send(method, **params) 
    else
      raise ArgumentError, "Invalid params type"
    end
      
    rpc_result = {
      jsonrpc: "2.0",
      result: result,
      id: rpc[:id]
    }
     
  rescue StandardError => e
    rpc_result = {
      jsonrpc: "2.0",
      error: {
        code: -32601,
        message: "Procedure not found.",
        data: e.to_s
      },
      id: rpc[:id]
    }
  end

  JSON.generate(rpc_result) + "\n"
end

stdin = IO.new(0)
loop do
  input = stdin.gets
  break if input.nil?

  begin
    json_data = JSON.parse(input, symbolize_names: true)
    
    output = do_rpc(json_data)
    $stdout.puts output
    $stdout.flush
  rescue JSON::ParserError
    print '{"jsonrpc": "2.0", "error": {"code": -32700, "message": "Parse error"}, "id": null}'
  end
end