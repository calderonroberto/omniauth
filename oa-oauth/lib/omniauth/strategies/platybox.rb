require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    # 
    # Authenticate to Platybox via OAuth and retrieve basic
    # user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::Platybox, 'consumerkey', 'consumersecret'
    #
    class Platybox < OmniAuth::Strategies::OAuth
      # Initialize the middleware
      #
      # @option options [Boolean, true] :sign_in When true, use the "Sign in with Platybox" flow instead of the authorization flow.
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :site => "http://api.platybox.com",
          :authorize_path => '/1/authenticate',
          :access_token_path => '/1/access_token',
          :request_token_path => '/1/request_token'
        }
        super(app, :platybox, consumer_key, consumer_secret, client_options, options)
      end
                
      def auth_hash
        ui = user_data
        OmniAuth::Utils.deep_merge(super, {        
          'uid' => ui['uid'],
          'user_info' => ui,
          'extra' => {'user_hash' => user_hash}
        })
      end
            
      def user_data
        user_hash = self.user_hash["user"]
        {
          'uid' => user_hash['id'],
          'nickname' => user_hash['username'],          
          'name' => user_hash['name'],
          'image' => user_hash['photo'],
          'description' => user_hash['description'],
          'urls' => {}
        }
      end
      
      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get('/1/users/show').body)
      end
      
    end
  end
end
