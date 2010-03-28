module Ajax
  module RailsHelpers
    # Container - The container to receive the response when the page is
    # rendered.
    # Tab - A jQuery selector that identifies a tab to activate when the response
    # is rendered.
    # Title - The page title of the page to be rendered.
    %w[container layout tab title controller].each do |header|
      define_method("set_response_#{header}") do |response, value|
        response.headers["Ajax-#{header.titleize}"] = value
      end
    end

    # Given a path, return a hash containing a tag(s) to set on the link.
    #
    # WillPaginate uses the <tt>rel</tt> tag on the page links, so I prefer
    # 'data-ajax-link'.
    def link_to_tag(address)
      { 'data-ajax-link' => address }
    end
  end
end