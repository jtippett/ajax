var AjaxClass = function() {
  var self = this;

  self.default_container = undefined;    // The default container
  self.loading_icon = $('#loading-icon-small');

  /**
   * Initialize
   *
   * Bind event handlers and setup jQuery Address.
   *
   */
  self.init = function(options) {
    self.default_container = options.default_container;

    // Configure jQuery Address
    $.address.history(true);
    $.address.change = self.loadPage;

    // Bind a live event to all ajax-enabled links
    $('a[data-deep-link]').click(self.linkClicked).live('click', self.linkClicked);
  };

  /**
   * loadPage
   *
   * Request new content and insert it into the document.  If the response
   * Ajax-Info header contains and of the following we take the associated
   * action:
   *
   *  [title] String, Set the page title
   *  [tab]   jQuery selector, trigger the 'activate' event on the tab
   *  [container] The container to receive the content, or <tt>main</tt> by default.
   *
   *  Cookies in the response are automatically set on the document.cookie.
   */
  self.loadPage = function() {
    if (document.location.pathname != '/') { return false; }

    self.loading_icon.show();
    $(document).bind('mousemove', self.updateImagePosition);

    jQuery.ajax({
      url: $.address.value().replace(/\/\//, '/'),
      method: 'GET',
      beforeSend: self.setRequestHeaders,
      success: self.responseHandler,
      complete: function(XMLHttpRequest, responseText) {
        $(document).unbind('mousemove', self.updateImagePosition);
        self.loading_icon.hide()
      },
      error: function(XMLHttpRequest, textStatus, errorThrown) {
        // Handle error page
        var responseText = $(XMLHttpRequest.responseText);
        if ($(responseText).find('body').size() > 0) {
          responseText = $(responseText).find('body').first();
        }
        self.responseHandler(responseText, textStatus, XMLHttpRequest);
      }
    });

    return true;
  };

  /**
   * responseHandler
   *
   * Set the AJAX_INFO request header.  This includes all the data
   * defined on the main (or receiving) container, plus some other
   * useful information like the:
   *
   * referer - the full referer URL including the hashed part.
   *
   */
  self.setRequestHeaders = function(XMLHttpRequest) {
    var data = self.default_container.data('ajax-info');
    if (data === undefined) { data = {}; }
    data['referer'] = document.location;
    XMLHttpRequest.setRequestHeader('AJAX_INFO', $.toJSON(data));
  };

  /**
   * linkClicked
   *
   * Called when the an AJAX-enabled link is clicked.
   * Redirect back to the root URL if we are not on it.
   *
   */
  self.linkClicked = function(event) {
    if (document.location.pathname != '/') {
      var url = $.address.baseURL().replace(new RegExp(document.location.pathname), '')
      url += '/#/' + $(this).attr('data-deep-link');
      url.replace(/\/\//, '/');
      document.location = url;
    } else {
      $.address.value($(this).attr('data-deep-link'));
    }
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
    container.html(responseText).data('ajax-info', data);

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
   * Process the response headers.
   *
   * Set the page title.
   */
  self.processResponseHeaders = function(XMLHttpRequest) {
    var data = XMLHttpRequest.getResponseHeader('Ajax-Info');
    if (data !== null) {
      try { data = jQuery.parseJSON(data); }
      catch(e) {
        console.log('Failed to parse Ajax-Info header as JSON!  Got ' + data);
      }
    }
    if (data === null || data === undefined) {
      data = {};
    }
    return data;
  };

  /**
   * Update the position of the loading icon.
   */
  self.updateImagePosition = function(e) {
    //console.log((e.pageY + 10)+'px');
    $('#loading-icon-small').css({
      layer: 100,
      position: 'absolute',
      top: e.pageY,
      left: e.pageX
    });
  }
};