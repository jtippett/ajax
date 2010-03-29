var AjaxClass = function() {
  var self = this;

  self.default_container = undefined;    // The default container
  self.loading_icon = $('#loading-icon-small');

  self.init = function(options) {
    self.default_container = options.default_container;

    // Configure jQuery Address
    $.address.history(true);
    $.address.change = self.loadPage;

    // Bind a live event to all ajax-enabled links
    $('a[data-deep-link]').click(self.linkClicked).live('click', self.linkClicked);
  };

  self.loadPage = function() {
    self.loading_icon.show();
    $(document).bind('mousemove', self.updateImagePosition);

    jQuery.ajax({
      url: $.address.value(),
      data: self.requestParameters(),
      method: 'GET',
      beforeSend: function(XMLHttpRequest) {
        XMLHttpRequest.setRequestHeader('AJAX_LAYOUT', 'boo');
      },
      success: self.responseHandler,
      complete: function(XMLHttpRequest, responseText) {
        $(document).unbind('mousemove', self.updateImagePosition);
        self.loading_icon.hide()
      },
      error: function(XMLHttpRequest, textStatus, errorThrown) {
        self.responseHandler(XMLHttpRequest.responseText, textStatus, XMLHttpRequest);
      }
    });

    return true;
  };

  self.updateImagePosition = function(e) {
    //console.log((e.pageY + 10)+'px');
    $('#loading-icon-small').css({
      layer: 100,
      position: 'absolute',
      top: e.pageY,
      left: e.pageX
    });
  }

  /**
   * linkClicked
   *
   * Called when the an AJAX-enabled link is clicked.
   *
   */
  self.linkClicked = function(event) {
    console.log('Clicked link '+$(this).attr('data-deep-link'));
    $.address.value($(this).attr('data-deep-link'));
    return false;
  };

  /**
   * responseHandler
   *
   * Process the response of an AJAX call and put the contents in
   * the appropriate container, activate tabs etc.
   *
   */
  self.responseHandler = function(responseText, textStatus, XMLHttpRequest) {
    var data = self.processResponseHeaders(XMLHttpRequest);
    var container = data.container === undefined ? self.default_container : $(data.container);

    console.log('Using container ',container.selector);
    console.log('Set data ',data);
    container.html(responseText).data('ajax', data);

    if (data.title !== undefined) {
      console.log('Using page title '+data.title);
      $.address.title(data.title);
    }
    if (data.tab !== undefined) {
      console.log('Activating tab '+data.tab);
      $(data.tab).trigger('activate');
    }

    // Set cookies
    var cookie = XMLHttpRequest.getResponseHeader('Set-Cookie');
    if (cookie !== null) {
      console.log('Setting cookie');
      document.cookie = cookie;
    }
  };

  /**
   * Return an Array or string of query parameters that will be
   * sent with the AJAX request.
   */
  self.requestParameters = function() {
    return '';
  };

  /**
   * Process the response headers.
   *
   * Set the page title.
   */
  self.processResponseHeaders = function(XMLHttpRequest) {
    var data = XMLHttpRequest.getResponseHeader('Ajax-Info');
    if (data !== null) {
      data = jQuery.parseJSON(data);
    } else {
      data = {};
    }
    return data;
  };
};

var Ajax = new AjaxClass();
$(function() {
  Ajax.init({
    default_container: $('#main')
  });
});