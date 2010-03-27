var AjaxClass = function() {
  var self = this;

  self.default_container = undefined;    // The default container
  self.loading_icon = $('#loading-icon-small');
  self.reset = function() {
    self.container = undefined;          // The current container
    self.tab = undefined;                // tab to activate
    self.layout = undefined;             // the current layout
    self.page_title = undefined;         // the current page layout
  };
  self.reset();

  self.init = function(options) {
    self.default_container = options.default_container;

    // Configure jQuery Address
    $.address.history(true);
    $.address.change = self.loadPage;
    // $.address.internalChange = self.internalChange;
    // $.address.externalChange = self.externalChange;

    // Bind a live event to all ajax-enabled links
    $('a[data-deep-link]').click(self.linkClicked).live('click', self.linkClicked);
  };

  // self.internalChange = function(event) {
  //   // beforeSend: function(){
  //   console.log('Internal change');
  //   return self.loadPage(event);
  // };
  //
  // self.externalChange = function(event) {
  //   // beforeSend: function(){
  //   //    // Handle the beforeSend event
  //   //  },
  //       console.log('External change');
  //   return self.loadPage(event);
  // };

  self.loadPage = function() {
    //console.log('x '+e.pageX+' y '+e.pageY);

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
    self.reset();
    self.processResponseHeaders(XMLHttpRequest);

    var container = self.container || self.default_container;
    console.log('Using container '+container.selector);
    container.html(responseText);

    console.log('Using layout '+self.layout);
    if (self.page_title !== undefined) {
      console.log('Using page title '+self.page_title);
      $.address.title(self.page_title);
    }
    if (self.tab !== undefined) {
      console.log('Activating tab '+self.tab);
      self.tab.trigger('activate');
    }
  };

  /**
   * Return an Array or string of query parameters that will be
   * sent with the AJAX request.
   */
  self.requestParameters = function() {
    params = {};
    if (self.layout !== undefined) {
      params.layout = self.layout;
    }
    return jQuery.param(params);
  };

  /**
   * Process the response headers.
   *
   * Set the page title.
   */
  self.processResponseHeaders = function(XMLHttpRequest) {
    var page_title = XMLHttpRequest.getResponseHeader('Ajax-Title');
    if (page_title !== null) {
      self.page_title = page_title;
    }
    var layout = XMLHttpRequest.getResponseHeader('Ajax-Layout');
    if (layout !== null) {
      self.layout = layout;
    }
    var container = XMLHttpRequest.getResponseHeader('Ajax-Container');
    if (container !== null) {
      self.container = $(container);
    }
    var tab = XMLHttpRequest.getResponseHeader('Ajax-Tab');
    if (tab !== null) {
      self.tab = $(tab);
    }
  };
};

var Ajax = new AjaxClass();
$(function() {
  Ajax.init({
    default_container: $('#main')
  });
});