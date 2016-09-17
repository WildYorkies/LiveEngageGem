require 'rubygems'
require 'oauth'
require 'json'
#require 'open-uri'
require 'net/http'

#consumer = OAuth::Consumer.new(consumer_key, consumer_secret, {:site=>'http://my.site'})
#accesstoken = OAuth::AccessToken.new(consumer, access_token, access_token_secret)
#json_response = accesstoken.get('/photos.xml')
#response = JSON.parse(json_response.body)

class Service
    def initialize(service_name)
        @base_uri = ''
        @name = service_name
    end
    def get_base_uri(account_id)
        uri = URI.parse("https://api.liveperson.net/api/account/#{account_id}/service/#{@name}/baseURI.json?version=1.0")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        data_hash = JSON.parse(response.body)
        @base_uri = data_hash['baseURI']
    end
    def to_s
        "#{self.class}\n\t#{@name} => #{@base_uri}"
    end
end

class EngagementHistory < Service
    def initialize
        super('engHistDomain')
    end
    def post(from = nil, to  = nil)

    end
end

class OperationalRealTime < Service
    def initialize
        super('leDataReporting')
    end
    def get(timeframe = nil, in_buckets_of = nil)
    end
end

class IvrDeflectionEngagement < Service
    def initialize
        super('smt')
    end
end

class UserManagement < Service
    def initialize(read_only = false)
        if read_only
            super('accountConfigReadOnly')
        else
            super('accountConfigReadWrite')
        end
    end
end

class Users < UserManagement
end

class Agents < UserManagement
end

class AgentGroups < UserManagement
end

class Application
    attr_reader :tokens, :account_id
    def initialize(account_id, tokens)
        @account_id = account_id
        @tokens = tokens
        @services = []
    end
    def oauth_sig
        #consumer = OAuth::Consumer.new(@tokens[:consumer_key], @tokens[:consumer_secret], {:site=>'http://my.site'})
        #accesstoken = OAuth::AccessToken.new(consumer, @tokens[:access_token], @tokens[:access_token_secret])
        #return accesstoken.to_s
    end
end

app = Application.new('89119334', {consumer_key: 'fdsafdsa', 
                                   consumer_secret: 'fdsafdsa', 
                                   access_token: 'fdsafdsa', 
                                   access_token_secret: 'fdsafdsa'})
users_api = Users.new
users_api.get_base_uri(app.account_id)
user_data = users_api.get
