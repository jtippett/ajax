/**
 * AjaxAssets
 *
 * A class representing an Array of assets.  Call with an instance of
 * Array which will be extended with special methods.
 *
 * Example: self.javascripts = new AjaxAssets([]);
 *
 * Once an asset is loaded, it is not loaded again.  Pass with the
 * following values:
 *
 * Ajax-Info{}
 *    assets{}
 *      javascripts []
 *      stylesheets []
 *
 */
var AjaxAssets = function(array) {
  return jQuery.extend(array, {
    /**
     * Add an asset, but don't load it.
     */
    addAsset: function(path) {
      this.push(this.sanitizePath(path));
    },
    
    /**
     * Load and add an asset.  The asset is loaded using the
     * unsanitized path should you need to put something in the
     * query string.
     */
    loadAsset: function(path) {
      console.log('[ajax] loading asset', path);
      this.push(this.sanitizePath(path));
      this.appendScriptTag(path);
    },

    /**
     * Return a boolean indicating whether an asset has
     * already been loaded.
     */    
    loadedAsset: function(path) {
      path = this.sanitizePath(path);
      for (var i=0; i < this.length; i++) {
        if (this[i] == path) {
          return true;
        }
      }
      return false;      
    },

    /**
     * Remove query strings and otherwise cleanup paths
     * before adding them.
     */    
    sanitizePath: function(path) {
      return path.replace(/\?.*/, '');
    },
    
    /**
     * Supports debugging and references the script files as external resources
     * rather than inline.
     *
     * @see http://stackoverflow.com/questions/690781/debugging-scripts-added-via-jquery-getscript-function
     */  
    appendScriptTag: function(url, callback) {
      var head = document.getElementsByTagName("head")[0];
      var script = document.createElement("script");
      script.src = url;
      
      { // Handle Script loading
         var done = false;

         // Attach handlers for all browsers
         script.onload = script.onreadystatechange = function(){
            if ( !done && (!this.readyState ||
                  this.readyState == "loaded" || this.readyState == "complete") ) {
               done = true;
               if (callback)
                  callback();

               // Handle memory leak in IE
               script.onload = script.onreadystatechange = null;
            }
         };
      }
      head.appendChild(script);
      return undefined;
    }  
  });
};

/**
 * Class Ajax
 *
 * Options:
 *    <tt>enabled</tt>  boolean indicating whether the plugin is enabled.
 *      This must be set if you are using Ajax callbacks in your code,
 *      and you want them to still fire if Ajax is not enabled.
 *
 *    <tt>default_container</tt>  string jQuery selector of the default 
 *      container element to receive content.
 *
 * Callbacks:
 *
 * Callbacks can be specified using Ajax-Info{ callback: 'javascript to eval' },
 * or by adding callbacks to your Ajax instance e.g.
 * 
 *    window.ajax.addCallback(function() { doSomething(args); });
 */ 
var Ajax = function(options) {
  var self = this;

  self.enabled = true;
  self.default_container = undefined;
  self.loaded_by_framework = false;
  self.loading_icon = $('#loading-icon-small');
  self.javascripts = undefined;
  self.callbacks = [];
  
  // Parse options
  self.options = options;  
  self.default_container = options.default_container;
  if (options.enabled !== undefined) {
    self.enabled = options.enabled;
  }

  // Initialize on DOM ready
  $(function() { self.init() });
        
  /**
   * Initializations run on DOM ready.
   *
   * Bind event handlers and setup jQuery Address.
   */
  self.init = function() {
    
    // Configure jQuery Address
    $.address.history(true);
    $.address.change = self.addressChanged;

    // Insert loading image
    var image = '<img src="/images/loading-icon-small.gif" id="loading-icon-small" alt="Loading..." />'
    $(image).hide().appendTo($('body'));
    
    // Bind a live event to all ajax-enabled links
    $('a[data-deep-link]').live('click', self.linkClicked);
    
    // Initialize the list of javascript assets
    if (self.javascripts === undefined) {
      self.javascripts = new AjaxAssets([]);
      
      $(document).find('script[type=text/javascript][src!=]').each(function() {
        var script = $(this);
        var src = script.attr('src');
        
        // Local scripts only
        if (src.match(/^\//)) {
          
          // Parse parameters passed to the script via the query string.
          // TODO: Untested.  It's difficult for us to use this with Jammit.
          if (src.match(/\Wajax.js\?.+/)) {
            var params = src.split('?')[1].split('&');
            jQuery.each(params, function(idx, param) {
              param = param.split('=');
              if (param.length == 1) { return true; }
              
              switch(param[0]) {
                case 'enabled':
                  self.enabled = param[1] == 'false' ? false : true;
                  console.log('[ajax] set param enabled=', self.enabled);
                  break;
                case 'default_container':
                  self.default_container = param[1];
                  console.log('[ajax] set param default_container=', self.default_container);
                  break;
              }
            });
          }
          
          self.javascripts.addAsset(script.attr('src'));
        }
      });
    }
  };
  
  /**
   * jQuery Address callback triggered when the address changes.
   */
  self.addressChanged = function() {
    if (document.location.pathname != '/') { return false; }

    if (typeof(self.loaded_by_framework) == 'undefined' || self.loaded_by_framework != true) { 
      self.loaded_by_framework = true;
      return false; 
    }    
    
    self.loadPage({ 
      url: $.address.value().replace(/\/\//, '/')
    });
    return true;
  };
  
  /**
   * loadPage
   *
   * Request new content and insert it into the document.  If the response
   * Ajax-Info header contains any of the following we take the associated
   * action:
   *
   *  [title]      String, Set the page title
   *  [tab]        jQuery selector, trigger the 'activate' event on the tab
   *  [container]  The container to receive the content, or <tt>main</tt> by default.
   *  [assets]     Assets to load
   *  [callback]   Execute a callback after assets have loaded
   *
   *  Cookies in the response are automatically set on the document.cookie.
   */
  self.loadPage = function(options) {
    if (!self.enabled) { 
      document.location = options.url;
      return true;
    }
    
    $(document).bind('mousemove', self.updateImagePosition);
    $('#loading-icon-small').show();

    jQuery.ajax({
      url: options.url,
      method: options.method || 'GET',
      beforeSend: self.setRequestHeaders,
      success: self.responseHandler,
      complete: function(XMLHttpRequest, responseText) {
        $(document).unbind('mousemove', self.updateImagePosition);
        $('#loading-icon-small').hide()
      },
      error: function(XMLHttpRequest, textStatus, errorThrown) {
        var responseText = XMLHttpRequest.responseText;
        self.responseHandler(responseText, textStatus, XMLHttpRequest);
      }
    });
  };

  /**
   * setRequestHeaders
   *
   * Set the AJAX_INFO request header.  This includes all the data
   * defined on the main (or receiving) container, plus some other
   * useful information like the:
   *
   * referer - the current document.location
   *
   */
  self.setRequestHeaders = function(XMLHttpRequest) {
    var data = $(self.default_container).data('ajax-info');
    if (data === undefined || data === null) { data = {}; }
    data['referer'] = document.location.href;
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
    var container = data.container === undefined ? $(self.default_container) : $(data.container);

    // Redirect?  Let the JS execute.  It will set the new window location.
    if (responseText && responseText.match(/try\s{\swindow\.location\.href/)) { return true; }

    // Full HTML document?  Extract the body
    if (responseText.search(/<\s*body[^>]*>/) != -1) {
      var start = responseText.search(/<\s*body[^>]*>/);
      start += responseText.match(/<\s*body[^>]*>/)[0].length;
      var end   = responseText.search(/<\s*\/\s*body\s*\>/);

      console.log('Extracting body ['+start+'..'+end+'] chars');
      responseText = responseText.substr(start, end - start);
    }

    // Insert the response into the container
    console.log('Using container ',container.selector);
    console.log('Set data ',data);
    container.data('ajax-info', data)
    container.html(responseText);

    // Handle special header instructions
    //  title    - set page title
    //  tab      - activate a tab
    //  assets   - load assets
    //  callback - execute a callback
    if (data.title !== undefined) {
      console.log('Using page title '+data.title);
      $.address.title(data.title);
    }
    
    if (data.tab !== undefined) {
      console.log('Activating tab '+data.tab);
      $(data.tab).trigger('activate');
    }
    
    // Load assets
    if (data.assets !== undefined && data.assets.javascripts !== undefined) {
      jQuery.each(jQuery.makeArray(data.assets.javascripts), function(idx, script) {
        if (self.javascripts.loadedAsset(script)) {
          console.log('[ajax] skipping asset', script);
          return true;
        } else {
          self.javascripts.loadAsset(script);
        }
      });
    }
    
    // Callback specified in header
    if (data.callback !== undefined) {
      self.executeCallback(data.callback);    
    }
    
    // Registered callbacks
    if (self.callbacks.length > 0) {
      jQuery.each(self.callbacks, function(idx, callback) {
        self.executeCallback(callback);
      });
      self.callbacks = [];
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
        console.log('Failed to parse Ajax-Info header as JSON!', data);
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
    //console.log(e.pageY);
    $('#loading-icon-small').css({
      layer: 100,
      position: 'absolute',
      top: e.pageY,
      left: e.pageX
    });
  };

  
  /**
   * addCallback
   *
   * Register a callback to be executed in the global scope
   * once all Ajax assets have been loaded.
   *
   * If the plugin is disabled, callbacks are executed immediately
   * on DOM ready.
   */
  self.addCallback = function(callback) {
    if (self.enabled) {
      self.callbacks.push(callback);
      console.log('[ajax] registered callback');
    } else {
      self.executeCallback(callback, true);
    }
  };

  /**
   * Execute a callback given as a string or function reference.
   *
   * <tt>dom_ready</tt> (optional) boolean, if true, the callback
   * is wrapped in a DOM-ready jQuery callback.
   */
  self.executeCallback = function(callback, dom_ready) {
    if (dom_ready !== undefined && dom_ready) {
      $(function() {
        self.executeCallback(callback);
      })
    } else { 
      console.log('[ajax] executing callback', callback);   
      try {
        if (jQuery.isFunction(callback)) {
          callback();
        } else {
          jQuery.globalEval(callback);
        }
      } catch(e) {
        console.log('[ajax] callback failed with exception', e);
      }
    }      
  };  
};