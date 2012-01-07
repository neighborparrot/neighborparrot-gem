module ActionView
  module Helpers
    module AssetTagHelper

      # URL helper for the parrot js client
      def neighborparrot_include_tag
        tag("img", { :a => 'ppp'})
      end
    end
  end
end
