# redmine release notes

Do any of the following apply?

* You have to produce release notes for your projects
* You end up going through the roadmap issue by issue, writing release notes
  for each one, and it's a real pain
* You wish it was easier to check whether all the release notes have been done
  for a particular version
* You are on Redmine 2.0 or higher

If so, then this plugin may be just what you need.

## features

* Store release notes and release notes status (todo, done, not required) per
  issue.
* See how close the release notes for a certain version are to being finished.
* Generate release notes for a particular version.
* Define templates for generated release notes.
* Localizable; currently available in English, German, Russian, and French.

## install

Clone it.

    git clone git://github.com/hdgarrood/redmine_release_notes \
        /path/to/redmine/plugins/redmine_release_notes

Do the migrations.

    rake redmine:plugins:migrate

Load the default formats (optional, recommended). If you've been using 1.2.0,
this will read your formats.yml and put them into the database (which is what
you want).

    rake redmine:plugins:release_notes:load_default_formats

Restart redmine.

## upgrading from 1.2.0

As of 1.3.0, release notes status (ie, whether the release notes for an issue
are done, still todo, or not required) are no longer stored as an issue custom
field, but in the release notes table. This means that you need to get this
information out of the issue custom field, and into the release notes table.

The column is `release_notes.status` and the recognised values are `'todo'`,
`'done'`, and `'not_required'`.

This is probably the easiest way to go about it:

    UPDATE release_notes
    SET status = 'todo'
    WHERE issue_id in (
      SELECT customized_id
      FROM custom_values
      WHERE customized_type = 'Issue'
        AND value = 'Todo' -- or whatever your configured 'todo' status is
    );

You'll need to run two more similar statements for `'done'` and
`'not_required'` release notes.

## setup

Before you can use it, you need to:

* Enable the release notes module for any relevant projects
* Enable release notes for the appropriate trackers

## use

Create release notes from the issue page; a section will appear under the
description, allowing you to add release notes and also mark whether the
release notes are done, todo, or not required.

Once a version is nearing completion, click on the Release notes tab on the
project menu to see a list of versions (like the roadmap) together with a
progress bar, showing how many release notes are done, and how many are still
left to do.

Chastise developers who haven't done their release notes by using the query
filters on the issue list.

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
