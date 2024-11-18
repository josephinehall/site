# frozen_string_literal: true

module Site
  class Routes < Hanami::Routes
    root to: "pages.home"

    get "/community", to: "pages.community"
  end
end
