# frozen_string_literal: true

module Site
  module Content
    class GenerateRedirects
      include Deps["repos.doc_repo"]

      def call
        redirects = []

        Content::DEFAULT_GUIDE_VERSIONS.each do |org, version|
          redirects
            .push("/guides/#{org}    /guides/#{org}/#{version}")
            .push("/guides/#{org}/*  /guides/#{org}/#{version}/:splat")
        end

        doc_repo.latest_by_org.values.flatten.each do |doc|
          redirects
            .push("/docs/#{doc.slug}    /docs/#{doc.slug}/#{doc.version}")
            .push("/docs/#{doc.slug}/*  /docs/#{doc.slug}/#{doc.version}/:splat")
        end

        redirects.join("\n")
      end
    end
  end
end
