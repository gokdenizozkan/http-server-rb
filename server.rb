require "socket"

class Response
  HTTP_VERSION = {:v1_1 => "HTTP/1.1"}
  HTTP_STATUS = {:ok => 200, :created => 201, :not_found => 404, :bad_request => 400}

  def self.of
    new
  end

  def self.ok(body=nil, content_type=nil)
    new.version(:v1_1).status(:ok).body(body).content_type(content_type)
  end

  def self.created(body=nil, content_type=nil)
    if body.nil? and content_type.nil?
      new.version(:v1_1).status(:created)
    end
    new.version(:v1_1).status(:created).body(body).content_type(content_type)
  end

  def self.not_found
    new.version(:v1_1).status(:not_found)
  end

  def self.bad_request
    new.version(:v1_1).status(:bad_request)
  end

  def version(v)
    @version = v
    return self
  end

  def status(s)
    @status = s
    return self
  end

  def content_length(cl)
    @content_length = cl
    return self
  end

  def content_type(ct)
    @content_type = ct
    return self
  end

  def body(b)
    @body = b
    @content_length = b.length unless b.nil?
    return self
  end

  def to_s
    response_line = "#{HTTP_VERSION[@version]} #{HTTP_STATUS[@status]} #{@status.to_s.split('_').join(' ').upcase}\r\n"
    return response_line + "\r\n" if @body.nil?

    "#{response_line}Content-Type: #{@content_type}\r\nContent-Length: #{@content_length}\r\n\r\n#{@body}"
  end
end

puts "Logging starts..."
puts ARGV[1]

server = TCPServer.new("localhost", 1423)

loop do
  Thread.start(server.accept) do |client|
    method, path, _ = client.gets.split
  
    headers = {}
    while line = client.gets.split(' ', 2)
      break if line[0] == ""
      headers[line[0].chop] = line[1].strip
    end

    options = ARGV.each_slice(2).to_h

    case method
    when "GET"
      response = case path
                when '/'
                  Response.ok
                when /\/echo\/(.*)/
                   Response.ok($1, 'text/plain').to_s
                when '/user-agent'
                  Response.ok(headers['User-Agent'], 'text/plain').to_s
                when /\/files\/(.*)/
                  file_path = "#{options["--directory"]}/#{$1}"
                  if File.exist?(file_path)
                    file_content = File.binread(file_path)
                    Response.ok(file_content, 'application/octet-stream').to_s
                  else
                    Response.not_found.to_s
                  end
                else
                  Response.not_found.to_s  
                end
      client.puts response
    when "POST"
      response = case path
                when /\/files\/(.*)/
                  file_path = "#{options["--directory"]}/#{$1}"
                  content_length = headers["Content-Length"].to_i
                  file_content = client.read(content_length)
                  File.binwrite(file_path, file_content)
                  Response.created.to_s
                else
                  Response.bad_request.to_s
                end
      client.puts response
    end
    client.close
  end
end