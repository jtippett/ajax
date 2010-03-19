$.address.history(true);
$.address.change(function(event) {
  console.log('Address changed');
});

var AjaxClass = function() {
  var self = this;

  self.loadPage = function(container) {
    container.load($.address.value());
  };
};

var Ajax = new AjaxClass();