# frozen_string_literal: true

module Site
  module Actions
    module Blog
      class Index < Site::Action
        def handle(request, response)
          response.render(
            view,
            page: Types::PageNumber[request.params[:page]]
          )
        end
      end
    end
  end
end
