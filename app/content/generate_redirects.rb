# frozen_string_literal: true

module Site
  module Content
    class GenerateRedirects
      def call
        # Loop over the latest version of each guide and doc

        # Generate lines like this for each:
        #
        # /docs/dry-types     /docs/dry-types/v1.8
        # /docs/dry-types/*   /docs/dry-types/v1.8/:splat

        <<~STR
          /docs/dry-types /docs/dry-types/v1.8
          /docs/dry-types/* /docs/dry-types/v1.8/:splat
        STR
      end
    end
  end
end
