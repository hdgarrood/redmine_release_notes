# redmine release notes

Do any of the following apply?

* You have to produce release notes for your projects
* You end up going through the roadmap issue by issue, writing release notes
  for each
* You wish it was easier to check whether all the release notes have been done
  for a particular version

If so, then this plugin may be just what you need.

## install

As on [redmine wiki:plugins][]

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

## features

* Create/read/update/delete release notes per issue. This is done from the
  issue's "show" page (ie, what you go to after entering its ID in the search
  box).
* Show a list of versions, together with how close the release notes are to
  being done. Done from "Release notes" tab in project menu.
* Generate release notes for a particular version.
* Define templates for generated release notes.
* Localizable - currently there are English, German, Russian, and French
  translations.

## docs

* [setup guide (for admins)](setup-guide)]
* [usage guide](setup-guide)]

## links

* [source](https://github.com/hdgarrood/redmine_release_notes)
* [issue tracker](https://github.com/hdgarrood/redmine_release_notes/issues)

[redmine wiki:plugins]: http://www.redmine.org/projects/redmine/wiki/Plugins "Redmine's wiki page for plugins"
