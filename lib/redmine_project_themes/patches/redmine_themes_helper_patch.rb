# encoding: utf-8
#
# Redmine plugin for providing project specific themes
#
# Copyright © 2019-2020 Stephan Wenzel <stephan.wenzel@drwpatent.de>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

module RedmineProjectThemes
  module Patches
    module RedmineThemesHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        
        base.class_eval do
          unloadable

          def get_project_theme(project=@project)
            return nil unless project

            case
            when project.module_enabled?(:redmine_project_themes) && project.theme.present?
              project.theme
            when project.parent.present?
              get_project_theme(project.parent)
            else
              nil
            end
          end
          
          def current_theme
            #
            # set new @current_theme if..
            #   ..@current_theme is not set
            #   ..@project has changed
            #
            unless instance_variable_defined?(:@current_theme) || instance_variable_defined?(:@current_project) && @current_project == @project
              @current_project = @project
              @current_theme   = get_project_theme(@project) || Redmine::Themes.theme(Setting.ui_theme)
            end
            
            @current_theme
              
          end #def
          
        end
      end
      
      module InstanceMethods
      end
    end
  end
end

unless Redmine::Themes::Helper.included_modules.include?(RedmineProjectThemes::Patches::RedmineThemesHelperPatch)
  Redmine::Themes::Helper.send(:include, RedmineProjectThemes::Patches::RedmineThemesHelperPatch)
end