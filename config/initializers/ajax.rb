# Default Ajax initialization file

# Configure paths that will bypass Ajax handling:
#
#   Ajax.exclude_paths %w[ /login /logout /signup /user-session/new ]
#   Ajax.exclude_paths [%r[\/my-account\/.*]]

# If you use a custom <tt>Rack::Ajax.decision_tree</tt>, include your 
# parser extensions in the Rack::Ajax::Parser module.
#
# The extensions define custom methods that are used in the
# <tt>Rack::Ajax.decision_tree</tt>.
#
#   Rack::Ajax::Parser.send(:include, Rack::Ajax::Parser::Extensions)