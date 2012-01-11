module ActionView
  module Helpers
    module AssetTagHelper

      NEIGHBORPARROT_JS_API = '/js/parrot.js'
      NEIGHBORPARROT_JS_DUMMY_API = '/js/dummy-parrot.js'

      # URL helper for the parrot js client
      # If :dummy_tests is true, use a dummy parrot
      # avoiding connections with the server but
      # triggering onconnect
      def neighborparrot_include_tag
        config = Neighborparrot.configuration
        parrot_js = config[:dummy_connections] ? NEIGHBORPARROT_JS_DUMMY_API : NEIGHBORPARROT_JS_API
        src = "#{config[:assets_server]}#{parrot_js}"
        content_tag(:script, nil, { :type => 'text/javascript', :src => src })
      end
    end
  end
end
