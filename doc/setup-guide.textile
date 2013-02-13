# Install

As on Redmine's "plugins page":http://www.redmine.org/projects/redmine/wiki/Plugins:

1. Migrations.

    rake redmine:plugins:migrate [RAILS_ENV="production|development..."]

2. Load default data (optional, recommended)

    rake redmine:plugins:release_notes:load_default_data

3. Restart redmine

## To use the plugin for a project:

* Enable the module for that project
* Enable release notes for the appropriate trackers

## Defining your own formats

This can be done from Administration > Plugins. 
