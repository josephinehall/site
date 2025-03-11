# frozen_string_literal: true

module Site
  module Actions
    module Guides
      # Redirects versionless guide URLs to the latest version of the guide.
      #
      # This is a development-mode affordance only. Versionless guide redirects in production are
      # handled via generated Netlify redirect configuration.
      class Redirect < Site::Action
        include Deps["repos.guide_repo"]

        def handle(request, response)
          halt 404 if Hanami.env == :production

          latest_version = guide_repo.latest_version(org: request.params[:org])

          latest_url = "/guides/#{request.params[:org]}/#{latest_version}/#{request.params[:slug]}"
          latest_url += "/#{request.params[:path]}" unless request.params[:path].to_s.empty?

          response.redirect_to latest_url
        end
      end
    end
  end
end
