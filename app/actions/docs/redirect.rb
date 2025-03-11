# frozen_string_literal: true

module Site
  module Actions
    module Docs
      # Redirects versionless doc URLs to the latest version of the doc.
      #
      # This is a development-mode affordance only. Versionless doc redirects in production are
      # handled via generated Netlify redirect configuration.
      class Redirect < Site::Action
        include Deps["repos.doc_repo"]

        def handle(request, response)
          halt 404 if Hanami.env == :production

          latest_version = doc_repo.latest_version(slug: request.params[:slug])

          latest_url = "/docs/#{request.params[:slug]}/#{latest_version}"
          latest_url += "/#{request.params[:path]}" unless request.params[:path].to_s.empty?

          response.redirect_to latest_url
        end
      end
    end
  end
end
