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