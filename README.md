# Redmine release notes

This plugin is designed for projects where:

1. The redmine instance is not public, but developers need to be able to produce release notes for the users
2. The roadmap is insufficient - more detailed information than an issue's subject is required.

## Features

* Create/edit/update/delete release notes per issue. This is done from the issue's "show" page (ie, what you go to after entering its ID in the search box). A new section should appear below the issue's description, showing the release notes, and giving links to add/edit/delete
* Show a list of versions with release notes completion per version. This is based on the Roadmap page, and can be accessed by clicking on the Release notes tab on the project menu.
* Generate release notes per version. This can be done from the above page.

### Planned features

* Generated release notes in different formats:
  * HTML
  * Textile
  * Markdown
  * And more... (maybe)
* Localization

## Getting started

### Install

I'd recommend that you read all of the readme first, though.
Steps to install:

1. Download or clone the repository
2. Copy to vendor/plugins/redmine_release_notes
3. Do the migrations: <code>rake db:migrate_plugins [RAILS_ENV="production|development..."]</code>
4. Restart redmine
5. Create custom fields: <code>rake create_release_notes_custom_fields [RAILS_ENV="production|development..."]</code>

### How it works

The plugin detects completion of release notes by looking at the value of a custom field called "Release notes required", which it assumes takes the values:

* No - not applicable
* Yes - to be done
* Yes - done

Of course, this means that you can't rename this field once you've created it.
If you don't have a custom field like this, you can simply do:

<code>rake create_release_notes_custom_fields [RAILS_ENV="production|development..."]</code>

and the plugin will do it for you. If you do, alter it so that it can take these values. It should also be a filter.

The plugin also assumes that a boolean custom field for versions exists, called "Release notes generated", which should indicate whether the release notes have been finished and generated. When set to true, the version will no longer appear in the release notes index unless the "Show generated versions" is checked. That's all it does.

The rake task will also do this for you. Again, don't rename this field.

The plugin also adds a project module, so that it can be enabled per project.

### To use the plugin for a project:
* enable the module
* enable the release notes custom fields for the project
* enable the release notes custom fields for the appropriate trackers

**Each of these steps is essential to the plugin working correctly!**

Have a look at the [usage guide](https://github.com/hdgarrood/redmine_release_notes/wiki/Usage-Guide) for more info.