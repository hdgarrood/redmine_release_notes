Clicking the "Generate release notes" link in the release notes index (see [[Managing release notes]]) will produce a list of the release notes for that version:

![Generated release notes](http://pages.hdgarrood.me.uk/img/release_notes/generate-notes.PNG)

* If there are any issues where the "Release notes required" field is set to "Yes - to be done", the plugin will warn you, and it will give you a link which will take you to the issues list, filtered to show only those issues.
* If there are any issues where the "Release notes required" field is set to "Yes - done", but there are no release notes,  the plugin will warn you, and it can give you a list of these issues.
* You can hit the "Mark this version as generated" button, to make that version stop appearing by default in the release notes index.
* You can do `GET /release_notes/:version_id/generate?raw=true` to just get the raw release notes&mdash;useful in build scripts.

Back to [[Usage Guide]]