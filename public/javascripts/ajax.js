var AjaxClass = function() {
  var self = this;
  self.container = undefined;

  self.init = function(options) {
    self.container = options.container;

    $.address.history(true);
    $.address.change = self.loadPage;
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
    self.container.load($.address.value());
  };
};

var Ajax = new AjaxClass();
$(function() {
  Ajax.init({
    container: $('#main')
  });
});