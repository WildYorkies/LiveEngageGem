require 'rubygems'
require 'oauth'
require 'json'
require 'net/https'
require 'open-uri'

#consumer = OAuth::Consumer.new(consumer_key, consumer_secret)
#accesstoken = OAuth::AccessToken.new(consumer, access_token, access_token_secret)
#json_response = accesstoken.get('/photos.xml')
#response = JSON.parse(json_response.body)

class Service
    def initialize(name:)
        @base_uri = ''
        @name = name
    end
    def get_base_uri(account_id:)
        response = open("https://api.liveperson.net/api/account/#{account_id}/service/#{@name}/baseURI.json?version=1.0").read
        data = JSON.parse(response.body)
        @base_uri = data['baseURI']
        self
    end
    def to_s
        "#{self.class}\n\t#{@name} => #{@base_uri}"
    end
    def request(token:, method:, request_uri: nil, params: nil)
        uri = URI.parse(@base_uri)
        case method
        when :get
            request = Net::HTTP::Get.new(request_uri)
        when :post
            request = Net::HTTP::Post.new(request_uri)
        end
        token.sign!(request)
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
end

class OperationalRealTime < Service
    def initialize
        super(name: 'leDataReporting')
    end
end

class IvrDeflectionEngagement < Service
    def initialize
        super(name: 'smt')
    end
end

class Users < Service
    def initialize(read_only: false)
        read_only ? super(name: 'accountConfigReadOnly') : super(name: 'accountConfigReadWrite')
    end
end

class Agents < Service
    def initialize(read_only: false)
        read_only ? super(name: 'accountConfigReadOnly') : super(name: 'accountConfigReadWrite')
    end
end

class AgentGroups < Service
    def initialize(read_only: false)
        read_only ? super(name: 'accountConfigReadOnly') : super(name: 'accountConfigReadWrite')
    end
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

users_api = Users.new(read_only: true).get_base_uri(account_id: app.account_id)
agents_api = Agents.new.get_base_uri(account_id: app.account_id)
agent_groups_api = AgentGroups.new.get_base_uri(account_id: app.account_id)
ivr_deflection_api = IvrDeflectionEngagement.new.get_base_uri(account_id: app.account_id)
operational_api = OperationalRealTime.new.get_base_uri(account_id: app.account_id)
engagement_history_api = EngagementHistory.new.get_base_uri(account_id: app.account_id)

puts users_api, agents_api, agent_groups_api, ivr_deflection_api, operational_api, engagement_history_api
