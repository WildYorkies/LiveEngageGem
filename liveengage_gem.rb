require 'rubygems'
require 'oauth'
require 'json'
require 'net/https'

#consumer = OAuth::Consumer.new(consumer_key, consumer_secret)
#accesstoken = OAuth::AccessToken.new(consumer, access_token, access_token_secret)
#json_response = accesstoken.get('/photos.xml')
#response = JSON.parse(json_response.body)

class Service
    def initialize(name:)
        @base_uri = ''
        @name = name
    end
    def get_base_uri(app:)
        uri = URI.parse("https://api.liveperson.net/api/account/#{app.account_id}/service/#{@name}/baseURI.json?version=1.0")
        request = Net::HTTP::Get.new(uri.request_uri)
        #request.add_field['authorization'] = app.oauth  --if you need to add the sig 
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        #http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        response = http.start do |client|
            client.request(request)
        end
        data_hash = JSON.parse(response.body)
        @base_uri = data_hash['baseURI']
        self
    end
    def to_s
        "#{self.class}\n\t#{@name} => #{@base_uri}"
    end
    def request(app:, method:, request_uri: nil, params: nil)
        uri = URI.parse(@base_uri)
        case method
        when :get
            request = Net::HTTP::Get.new(request_uri)
        when :post
            request = Net::HTTP::Post.new(request_uri)
        end
        app.oauth.sign!(request)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        response = http.start do |client|
            yield client, request 
        end
    end
end

class EngagementHistory < Service
    def initialize
        super(name: 'engHistDomain')
    end
    def request(app:, method:, params: nil)
        super(app: app, method: :post, params: '/enghist/interactions') do |client, request|
            
        end
    end
end

class OperationalRealTime < Service
    def initialize
        super(name: 'leDataReporting')
    end
    def request(app:, method:, params: nil)
        super(app: app, method: :get, params: '/rtapi/details/') do |client, request|
            
        end
    end
end

class IvrDeflectionEngagement < Service
    def initialize
        super(name: 'smt')
    end
end

class UserManagement < Service
    def initialize(read_only: false)
        if read_only
            super(name: 'accountConfigReadOnly')
        else
            super(name: 'accountConfigReadWrite')
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
    def initialize(account_id:, tokens:)
        @account_id = account_id
        @tokens = tokens
    end
    def oauth
        consumer = OAuth::Consumer.new(@tokens[:consumer_key], @tokens[:consumer_secret])
        accesstoken = OAuth::AccessToken.new(consumer, @tokens[:access_token], @tokens[:access_token_secret])
        return accesstoken
        # call accesstoken.sign!(request, ) inside of the using method
    end
end

app = Application.new(account_id: 'xxx', tokens: {consumer_key: 'fdsafdsa', 
                                                       consumer_secret: 'fdsafdsa', 
                                                       access_token: 'fdsafdsa', 
                                                       access_token_secret: 'fdsafdsa'})

# TESTS 
p app, app.oauth

users_api = Users.new.get_base_uri(app: app)
agents_api = Agents.new.get_base_uri(app: app)
agent_groups_api = AgentGroups.new.get_base_uri(app: app)
ivr_deflection_api = IvrDeflectionEngagement.new.get_base_uri(app: app)
operational_api = OperationalRealTime.new.get_base_uri(app: app)
engagement_history_api = EngagementHistory.new.get_base_uri(app: app)

puts users_api, agents_api, agent_groups_api, ivr_deflection_api, operational_api, engagement_history_api
