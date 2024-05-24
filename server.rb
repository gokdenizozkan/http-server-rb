require "socket"

class Response
  @@HTTP_VERSION = {:v1_1 => "HTTP/1.1"}
  @@HTTP_STATUS = {:ok => 200, :created => 201, :not_found => 404}

  def self.of
    Response.new
  end

  def self.ok(body, content_type)
    Response.new.version(:v1_1).status(:ok).body(body).content_length(body.length).content_type(content_type)
  end

  def self.created(body, content_type)
    unless body and content_type
      Response.new.version(:v1_1).status(:created)
    end
    Response.new.version(:v1_1).status(:created).body(body).content_length(body.length).content_type(content_type)
  end

  def self.not_found
    Response.new.version(:v1_1).status(:not_found)
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
    return self
  end

  def to_s
    unless @body
      return "#{@@HTTP_VERSION[@version]} #{@@HTTP_STATUS[@status]} #{@status.to_s.split('_').join(' ').upcase}\r\n\r\n"
    end

    return "#{@@HTTP_VERSION[@version]} #{@@HTTP_STATUS[@status]} #{@status.to_s.split('_').join(' ').upcase}\r\n" +
    "Content-Type: #{@content_type}\r\n" +
    "Content-Length: #{@content_length}\r\n\r\n" +
    @body
  end
end

puts "Logging starts..."

server = TCPServer.new("localhost", 1423)

loop do
  Thread.start(server.accept) do |client|
    method, path, _ = client.gets.split
  
    headers = {}
    while line = client.gets.split(' ', 2)
      break if line[0] == ""
      headers[line[0].chop] = line[1].strip
    end

    options = {}
    (0...ARGV.length - 1).step(2).each do |i|
      options[ARGV[i]] = ARGV[i + 1]
    end

    case method
    when "GET"
      if path == "/"
        client.puts "HTTP/1.1 200 OK\r\n\r\n"
        client.puts headers
      elsif path.start_with?("/echo/")
        content = path.split("/").last
        client.puts Response.ok(content, "text/plain").to_s
      elsif path.start_with?("/user-agent")
        user_agent = headers["User-Agent"]
        client.puts Response.ok(user_agent, "text/plain").to_s
      elsif path.start_with?("/files/")
        file_name = path.split("/").last
        file_path = "#{options["--directory"]}/#{file_name}"
        if File.exist?(file_path)
          file = File.open(file_path, "rb")
          file_content = file.read
          client.puts Response.ok(file_content, "application/octet-stream").to_s
        else
          client.puts Response.not_found.to_s
        end
      else
        client.puts Response.not_found.to_s
      end
    when "POST"
      if path.start_with?("/files/")
        file_name = path.split("/").last
        file_path = "#{options["--directory"]}/#{file_name}"

        content_length = headers["Content-Length"].to_i
        file_content = client.read(content_length)

        File.open(file_path, "wb") { |file| file.write(file_content) }

        client.puts Response.created
      end
    end

    client.close
  end
end