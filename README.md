# redmine release notes

Do any of the following apply?

* You have to produce release notes for your projects
* You end up going through the roadmap issue by issue, writing release notes
  for each one, and you feel there's got to be a better way
* You wish it was easier to check whether all the release notes have been done
  for a particular version

If so, then this plugin may be just what you need.

## requirements

Just Redmine 2.1.0 or higher.

## features

* Store release notes with each issue.
* See how close the release notes for a certain version are to being finished.
* Generate release notes for a particular version.
* Define templates for generated release notes.
* Localizable; currently available in English, German, Russian, French, and
  Brazilian Portuguese.\*

\* Actually all of the languages other than English are a bit out of date now.
Pull requests welcome!

## install

Clone it.

    git clone git://github.com/hdgarrood/redmine_release_notes \
        /path/to/redmine/plugins/redmine_release_notes

Do the migrations.

    rake redmine:plugins:migrate

Load the default formats (optional, recommended). If you've been using earlier
versions, this will read your formats.yml and put them into the database (which
is what you want).

    rake redmine:plugins:release_notes:load_default_formats

Restart redmine.

## setup

Before you can use it, you need to:

* Do first-time configuration (Inside Redmine, go to Administration > Plugins
  > Redmine release notes > Configure)
* Enable the release notes module for any relevant projects
* Enable the release notes custom field for the appropriate trackers

## use

Create release notes from the issue page; a section will appear under the
description, allowing you to add release notes. Use the issue custom field to
mark whether the release notes are done, todo, or not required.

Once a version is nearing completion, click on the Release notes tab on the
project menu to see a list of versions (like the roadmap) together with a
progress bar, showing how many release notes are done, and how many are still
left to do.

Once a version is complete, generate release notes from the same place. You can
also get the release notes raw:

    GET /versions/:id/generate_release_notes?raw=true

Configure the templates used to generate release notes in Administration >
Plugins (if you're an admin).

## contributing

Bug reports, feature requests, and pull requests are all welcome.

* [source](https://github.com/hdgarrood/redmine_release_notes)
* [issue tracker](https://github.com/hdgarrood/redmine_release_notes/issues)

## licence

Copyright (C) 2012-2013 Harry Garrood.

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <http://www.gnu.org/licenses/>.
