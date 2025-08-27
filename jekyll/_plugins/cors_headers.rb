# CORS Headers Plugin for Jekyll Development Server
# Allows Giscus to load custom CSS from localhost

if Jekyll.env == 'development'
  require 'webrick'
  
  Jekyll::Hooks.register :site, :post_write do |site|
    # Add CORS support to WEBrick responses
    WEBrick::HTTPResponse.class_eval do
      unless method_defined?(:cors_setup_header)
        alias_method :cors_setup_header, :setup_header
        
        def setup_header
          cors_setup_header
          
          # Add CORS headers for CSS files
          if @request_uri && @request_uri.path.end_with?('.css')
            self['Access-Control-Allow-Origin'] = '*'
            self['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
            self['Access-Control-Allow-Headers'] = 'Content-Type'
          end
        end
      end
    end
  end
end