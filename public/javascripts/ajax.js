var AjaxClass = function() {
  var self = this;
  self.container = undefined;
  self.layout = undefined;

  self.init = function(options) {
    self.container = options.container;

    $.address.history(true);
    $.address.change = self.loadPage;

    var link_clicked = function(event) {
      console.log('Clicked link '+$(this).attr('data-deep-link'));
      $.address.value($(this).attr('data-deep-link'));
      return false;
    };
    $('a[data-deep-link]').click(link_clicked).live('click', link_clicked);
  };

  /**
   * loadPage
   *
   * Called when the address changes.
   *
   */
  self.loadPage = function(event) {
    console.log('Address changed to '+$.address.value());
    console.log('Loading '+$.address.value());
    self.container.load($.address.value(), self.processResponseHeaders);
  };

  /**
   * Return an Array or string of query parameters that will be
   * sent with the AJAX request.
   */
  self.requestParameters = function() {
    { layout: self.layout }
  };

  /**
   * Process the response headers.
   *
   * Set the page title.
   */
  self.processResponseHeaders = function(responseText, textStatus, request) {
    var page_title = request.getResponseHeader("Ajax-Page-Title");
    if (page_title !== null) {
      $.address.title(page_title);
    }
    var layout = request.getResponseHeader("Ajax-Layout");
    if (layout !== null) {
      console.log('Using layout '+layout);
      self.layout = layout;
    }
  };
};

var Ajax = new AjaxClass();
$(function() {
  Ajax.init({
    container: $('#main')
  });
});