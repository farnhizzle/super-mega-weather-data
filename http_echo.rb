class HttpEcho
  def initialize(app)
    @app = app
  end
  
  def call(env)
    dup._call(env)
  end
  
  def _call(env)
    @app.call(env)
    return
    
    if env['REQUEST_PATH'] == "/echo"
      content = YAML.dump(env)
      @status = 200
      @headers = {'Content-Type' => "text/plain", 'Content-Length' => content.length.to_s}
      @response = [content]
    else
      @status, @headers, @response = @app.call(env)
    end
    
    [@status, @headers, @response]
  end
end