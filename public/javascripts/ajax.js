/**  
*  Script lazy loader 0.5
*  Copyright (c) 2008 Bob Matsuoka
*
*  This program is free software; you can redistribute it and/or 
*  modify it under the terms of the GNU General Public License
*  as published by the Free Software Foundation; either version 2
*  of the License, or (at your option) any later version.
*/
 
var LazyLoader = {}; //namespace
LazyLoader.timer = {};  // contains timers for scripts
LazyLoader.scripts = [];  // contains called script references
LazyLoader.load = function(url, callback) {
  // handle object or path
  var classname = null;
  var properties = null;
  try {
    // make sure we only load once
    if (LazyLoader.scripts.indexOf(url) == -1) {
      // note that we loaded already
      LazyLoader.scripts.push(url);
      var script = document.createElement("script");
      script.src = url;
      script.type = "text/javascript";
      $(script).appendTo("head");  // add script tag to head element
      
      // was a callback requested
      if (callback) {    
        // test for onreadystatechange to trigger callback
        script.onreadystatechange = function () {         
          if (script.readyState == 'loaded' || script.readyState == 'complete') {
            callback();
          }
        };
                                    
        // test for onload to trigger callback
        script.onload = function () {  
          callback();
          return;
        };
        
        // safari doesn't support either onload or readystate, create a timer
        // only way to do this in safari
        if (($.browser.webkit && !navigator.userAgent.match(/Version\/3/)) || $.browser.opera) { // sniff
          LazyLoader.timer[url] = setInterval(function() {
            if (/loaded|complete/.test(document.readyState)) {
              clearInterval(LazyLoader.timer[url]);
              callback(); // call the callback handler
            }
          }, 10);
        }
      }
    } else {
      if (callback) { callback(); }
    }
  } catch (e) {
    alert(e);
  }
}

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
var AjaxAssets = function(array, type) {
  var DATA_URI_START = "<!--[if (!IE)|(gte IE 8)]><!-->";
  var DATA_URI_END   = "<!--<![endif]-->";
  var MHTML_START    = "<!--[if lte IE 7]>";
  var MHTML_END      = "<![endif]-->";

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
    loadAsset: function(path, callback) {
      console.log('[ajax] loading', type, path);
      this.push(this.sanitizePath(path));
      if (type == 'css') {
        this.appendScriptTag(path, callback);
      } else if ($.browser.msie || $.browser.mozilla) {
        this.appendScriptTag(path, callback);
      } else {
        LazyLoader.load(path, callback);
      }
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
      if (type == 'js') {
        var head = document.getElementsByTagName("head")[0];
        var script = document.createElement("script");
        script.src = url;
        script.type = 'text/javascript'
        head.appendChild(script);
        // Handle Script loading
        if (callback) {
           var done = false;
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
      } else if (type == 'css') {
        if (url.match(/datauri/)) {
          $(DATA_URI_START + '<link type="text/css" rel="stylesheet" href="'+ url +'">' + DATA_URI_END).appendTo('head');
        } else if (url.match(/mhtml/)) {
          $(MHTML_START + '<link type="text/css" rel="stylesheet" href="'+ url +'">' + MHTML_END).appendTo('head');
        } else {
          $('<link type="text/css" rel="stylesheet" href="'+ url +'">').appendTo('head');
        }
      }
      return undefined;
    }
  });
};

/**
 * Class Ajax
 *
 * Options:
 *    <tt>enabled</tt>  boolean indicating whether the plugin is enabled.
 *      Callbacks that you set in the Ajax-Info header or directly on
 *      this instance will still be executed.  They will not be queued,
 *      the will be executed immediately.
 *
 *    <tt>default_container</tt>  string jQuery selector of the default
 *      container element to receive content.
 *
 *    <tt>lazy_load_assets</tt>  boolean indicating whether to enable
 *      lazy loading assets.  If this is disabled, callbacks will be
 *      executed immediately.
 *
 *    <tt>show_loading_image</tt> (default true) boolean indicating whether
 *      to show the loading image.
 *
 *    <tt>loading_image</tt>  (optional) string jQuery selector of an
 *      existing image to show while pages are loading.  If not set the default
 *      selector is: img#ajax-loading
 *
 *    <tt>loading_image_path</tt> (optional) string full path to the loading
 *      image.  Used to append an image tag to the body element
 *      if an existing image is not found.  Default: /images/ajax-loading.gif
 *
 *      To customize image handling, override the <tt>showLoadingImage</tt> and
 *      <tt>hideLoadingImage</tt> methods.
 *
 * Callbacks:
 *
 * Callbacks can be specified using Ajax-Info{ callbacks: 'javascript to eval.' },
 * or by adding callbacks directly to the Ajax instance.
 *
 * 'onLoad' callbacks are executed once new content has been inserted into the DOM,
 * and after all assets have been loaded (if using lazy-loading). I.e. "on page load".
 *
 * For example:
 *
 *    window.ajax.onLoad(function() { doSomething(args); });
 *
 * To add a callback to the front of the queue use:
 *
 *    window.ajax.prependOnLoad(function() { doSomething(args); });
 *
 * KJV 2010-04-22: I've experienced problems with Safari using String callbacks.  YMMV.
 * Browser support for callbacks is patchy at this time so lazy-loading is
 * not recommended.
 */
var Ajax = function(options) {
  var self = this;
  
  /**
   * Options
   */
  self.options = {
    enabled: true,
    default_container: undefined,
    loaded_by_framework: false,
    show_loading_image: true,
    loading_image: 'img#ajax-loading',
    loading_image_path: '/images/ajax-loading.gif',
    javascripts: undefined,
    stylesheets: new AjaxAssets([], 'css'),
    callbacks: [],
    loaded: false,
    lazy_load_assets: false,

    // For initial position of the loading icon.  Often the mouse does not
    // move so position it by the link that was clicked.
    last_click_coords: undefined
  };
  jQuery.extend(self.options, options);
  jQuery.extend(self, self.options);

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

    // Bind a live event to all ajax-enabled links
    $('a[data-deep-link]').live('click', self.linkClicked);

    // Initialize the list of javascript assets
    if (self.javascripts === undefined) {
      self.javascripts = new AjaxAssets([], 'js');

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
    self.initialized = true;

    // Run onInit() callbacks
  };

  /**
   * jQuery Address callback triggered when the address changes.
   */
  self.addressChanged = function() {
    if (document.location.pathname != '/') { return false; }
    if (window.ajax.disable_address_intercept == true) {return false;}
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
    self.loaded = false;
    self.showLoadingImage();

    jQuery.ajax({
      url: options.url,
      method: options.method || 'GET',
      beforeSend: self.setRequestHeaders,
      success: self.responseHandler,
      complete: function(XMLHttpRequest, responseText) {
        // Scroll to the top of the page.
        $(document).scrollTop(0);
        self.hideLoadingImage();
        self.loaded = true;
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
      self.last_click_coords = { pageX: event.pageX, pageY: event.pageY };
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

    /**
     * Extract the body
    */
    if (responseText.search(/<\s*body[^>]*>/) != -1) {
      var start = responseText.search(/<\s*body[^>]*>/);
      start += responseText.match(/<\s*body[^>]*>/)[0].length;
      var end   = responseText.search(/<\s*\/\s*body\s*\>/);

      console.log('Extracting body ['+start+'..'+end+'] chars');
      responseText = responseText.substr(start, end - start);
    }

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

    /**
     * Load stylesheets
    */
    if (self.lazy_load_assets && data.assets && data.assets.stylesheets !== undefined) {
      jQuery.each(jQuery.makeArray(data.assets.stylesheets), function(idx, url) {
        if (self.stylesheets.loadedAsset(url)) {
          console.log('[ajax] skipping css', url);
          return true;
        } else {
          self.stylesheets.loadAsset(url);
        }
      });
    }

    /**
     * Insert response
    */
    console.log('Using container ',container.selector);
    console.log('Set data ',data);
    container.data('ajax-info', data)
    container.html(responseText);

    /**
     * Include callbacks from Ajax-Info
    */
    if (data.callbacks) {
      data.callbacks = jQuery.makeArray(data.callbacks);
      self.callbacks.concat(data.callbacks);
    }

    /**
     * Load javascipts
    */    
    if (self.lazy_load_assets && data.assets && data.assets.javascripts !== undefined) {
      var count = data.assets.javascripts.length;
      var callback;
      
      jQuery.each(jQuery.makeArray(data.assets.javascripts), function(idx, url) {
        if (self.javascripts.loadedAsset(url)) {
          console.log('[ajax] skipping js', url);
          return true;
        }
        
        // Execute callbacks once the last asset has loaded
        callback = (idx == count - 1) ? undefined : self.executeCallbacks;
        self.javascripts.loadAsset(url, callback);
      });
    } else {
      // Execute callbacks immediately
      self.executeCallbacks();
    }

    $(document).trigger('ajax.onload');
    
    /**
     * Set cookies - browsers don't seem to allow this
    */
    try {
      var cookie = XMLHttpRequest.getResponseHeader('Set-Cookie');
      if (cookie !== null) {
        console.log('Setting cookie');
        document.cookie = cookie;
      }
    } catch(e) {
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
   * Hide the loading image.
   *
   * Stop watching the mouse position.
   */
  self.hideLoadingImage = function() {
    if (!self.show_loading_image) { return; }
    $(document).unbind('mousemove', self.updateImagePosition);
    $(self.loading_image).hide();
  };

  /**
   * Show the loading image.
   */
  self.showLoadingImage = function() {
    if (!self.show_loading_image) { return; }

    var icon = $(self.loading_image);

    // Create the image if it doesn't exist
    if (icon.size() == 0)  {
      $('<img src="'+ self.loading_image_path +'" id="ajax-loading" alt="Loading..." />').hide().appendTo($('body'));
      icon = $(self.loading_image);
    }

    // Follow the mouse pointer
    $(document).bind('mousemove', self.updateImagePosition);

    // Display at last click coords initially
    if (self.last_click_coords !== undefined) {
      self.updateImagePosition(self.last_click_coords);

    // Center it
    } else {
      var marginTop  = parseInt(icon.css('marginTop'), 10);
      var marginLeft = parseInt(icon.css('marginLeft'), 10);
      marginTop      = isNaN(marginTop)  ? 0 : marginTop;
      marginLeft     = isNaN(marginLeft) ? 0 : marginLeft;
      
      icon.css({
        position:   'absolute',
        left:       '50%',
        top:        '50%',
        zIndex:     '99',
        marginTop:  marginTop  + jQuery(window).scrollTop(),
        marginLeft: marginLeft + jQuery(window).scrollLeft()
      });
    }
    icon.show();
  };

  /**
   * Update the position of the loading icon.
   */
  self.updateImagePosition = function(e) {
    $(self.loading_image).css({
      zIndex:   99,
      position: 'absolute',
      top:      e.pageY + 14,
      left:     e.pageX + 14
    });
  };

  /**
   * onLoad
   *
   * Register a callback to be executed in the global scope
   * once all Ajax assets have been loaded.  Callbacks are
   * appended to the queue.
   *
   * If the plugin is disabled, callbacks are executed immediately
   * on DOM ready.
   */
  self.onLoad = function(callback) {
    if (self.enabled && (self.lazy_load_assets && !self.loaded)) {
      self.callbacks.push(callback);
      console.log('[ajax] appending callback', self.teaser(callback));
    } else {
      self.executeCallback(callback, true);
    }
  };

  /**
   * prependOnLoad
   *
   * Add a callback to the start of the queue.
   *
   * @see onLoad
   */
  self.prependOnLoad = function(callback) {
    if (self.enabled && (self.lazy_load_assets && !self.loaded)) {
      self.callbacks.unshift(callback);
      console.log('[ajax] prepending callback', self.teaser(callback));
    } else {
      self.executeCallback(callback, true);
    }
  };

  /**
   * Execute callbacks
  */
  self.executeCallbacks = function() {
    var callbacks = jQuery.makeArray(self.callbacks);
    if (callbacks.length > 0) {
      jQuery.each(callbacks, function(idx, callback) {
        self.executeCallback(callback);
      });
      self.callbacks = [];
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
      console.log('[ajax] executing callback', self.teaser(callback));
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

  self.teaser = function(callback) {
    return new String(callback).slice(0,50);
  };

  /**
   * Escape all special jQuery CSS selector characters in *selector*.
   * Useful when you have a class or id which contains special characters
   * which you need to include in a selector.
   */
  self.escapeSelector = (function() {
    var specials = [
      '#', '&', '~', '=', '>',
      "'", ':', '"', '!', ';', ','
    ];
    var regexSpecials = [
      '.', '*', '+', '|', '[', ']', '(', ')', '/', '^', '$'
    ];
    var sRE = new RegExp(
      '(' + specials.join('|') + '|\\' + regexSpecials.join('|\\') + ')', 'g'
    );

    return function(selector) {
      return selector.replace(sRE, '\\$1');
    }
  })();
};