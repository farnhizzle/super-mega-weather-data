class SuperMega < Sinatra::Base
  
  #use Rack::Auth::Basic do |username, password|
  #  username == 'admin' && password == 'secret'
  #end
  
  get "/" do
    weather_keys = list_weather
    weather_formatted = weather_keys.collect do |key|
      weather = get_weather(key)
      "#{key}: (hi: #{weather[:hi]}, lo: #{weather[:lo]})"
    end
    <<-EOF
      This is the Super Mega Weather Data Service. Enjoy!<br /><br />
      <p>Our Weather:</p>
      <ul>
        <li>#{weather_formatted.join("</li><li>")}</li>
      </ul>
    EOF
  end
  
  #get "/weather"
  #get "/weather/:zip"
  
  post "/weather" do
    if weather_exists(params[:zip])
      status 409
      body "Already exists"
    else
      store_weather(params[:zip], { :hi => params[:hi], :lo => params[:lo] })
      status 201
      body "Created! So rad."
    end
  end
  
  #put "/weather/:zip"
  #delete "/weather/:zip"
    
  private
    def redis
      if ENV["REDISTOGO_URL"]
        uri = URI.parse(ENV["REDISTOGO_URL"])
        @redis ||= Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      else
        @redis ||= Redis.new
      end
    end
    
    def weather_exists(zip)
      redis.exists(zip)
    end
    
    def store_weather(zip, attributes)
      redis.mapped_hmset(zip, attributes)
    end
    
    def delete_weather(zip)
      redis.del(zip)
    end
  
    def get_weather(zip)
      redis.mapped_hmget(zip, :hi, :lo, :zip)
    end
  
    def list_weather
      redis.keys
    end
    
    def weather_to_xml(weather, root = true, version = 1)
      xml = <<-EOF
        #{'<?xml version="1.0"?>' if root}
        <weather>
          <zip>#{weather[:zip]}</zip>
          <hi>#{weather[:hi]}</hi>
          <lo>#{weather[:lo]}</lo>
        </weather>
      EOF
    end
end