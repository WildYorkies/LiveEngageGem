require 'rubygems'
require 'oauth'
require 'json'
#require 'open-uri'
require 'net/http'
#require 'openssl'
#OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

#consumer_key = 'f'
#consumer_secret = 'f'
#access_token = 'd'
#access_token_secret = 's'

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
end

class OperationalRealTime < Service
    def initialize
        super('leDataReporting')
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
    attr_reader :services, :tokens, :account_id
    def initialize(account_id, tokens)
        @account_id = account_id
        @tokens = tokens
        @services = []
    end
    def add_service(service)
        @services << service
    end
end

app = Application.new('89119334', {consumer_key: 'fdsafdsa', 
                                   consumer_secret: 'fdsafdsa', 
                                   access_token: 'fdsafdsa', 
                                   access_token_secret: 'fdsafdsa'})
s1 = EngagementHistory.new
s1.get_base_uri(app.account_id)
s2 = OperationalRealTime.new
s2.get_base_uri(app.account_id)
s3 = Users.new
s3.get_base_uri(app.account_id)
s4 = Agents.new(read_only = true)
s4.get_base_uri(app.account_id)
app.add_service(s1)
app.add_service(s2)
app.add_service(s3)
app.add_service(s4)
puts app.services
puts app.tokens
puts app.account_id
