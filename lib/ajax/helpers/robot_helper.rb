module Ajax
  module Helpers
    module RobotHelper
      ROBOTS = [
        {:name => 'Googlebot', :user_agent_regex => /\bGooglebot\b/i, :sample_agent_string => 'Googlebot'},
        {:name => 'Baidu', :user_agent_regex => /\bBaidu\b/i, :sample_agent_string => 'Baidu'},
        {:name => 'Gigabot', :user_agent_regex => /\bGigabot\b/i, :sample_agent_string => 'Gigabot'},
        {:name => 'libwww-perl', :user_agent_regex => /\blibwww-perl\b/i, :sample_agent_string => 'libwww-perl'},
        {:name => 'lwp-trivial', :user_agent_regex => /\blwp-trivial\b/i, :sample_agent_string => 'lwp-trivial'},
        {:name => 'Lynx', :user_agent_regex => /\bLynx\b/i, :sample_agent_string => 'Lynx'},
        {:name => 'MSNBot', :user_agent_regex => /\bmsnbot\b/i, :sample_agent_string => 'msnbot'},
        {:name => 'SiteUptime', :user_agent_regex => /\bSiteUptime\b/i, :sample_agent_string => 'SiteUptime'},
        {:name => 'Slurp', :user_agent_regex => /\bSlurp\b/i, :sample_agent_string => 'Slurp'},
        {:name => 'WordPress', :user_agent_regex => /\bWordPress\b/i, :sample_agent_string => 'WordPress'},
        {:name => 'ZIBB', :user_agent_regex => /\bZIBB\b/i, :sample_agent_string => 'ZIBB'},
        {:name => 'ZyBorg', :user_agent_regex => /\bZyBorg\b/i, :sample_agent_string => 'ZyBorg'},
      ]

      def robot_for(user_agent)
        ROBOTS.each do |r|
          return r if user_agent =~ r[:user_agent_regex]
        end
        nil
      end
    
      # Call with a User Agent string
      def is_robot?(user_agent)
        !!self.robot_for(user_agent)
      end    
    end
  end
end