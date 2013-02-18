Release Notes
=============

v1.3.0
------

* Loads of bugfixes
* Configuration is much simpler:
    * No longer uses issue custom field for release notes
    * No longer uses a version custom field; instead, closed versions are hidden by
      default on the release notes index
    * Release notes formats and plugin configuration now stored in the database
    * No more yaml files
* Improved form for editing release notes
* Preview formats while editing them
* No longer allow release notes to be marked as completed if their text is blank
* Ability to choose trackers which can have release notes
* Compatible with Redmine 2.1.0 or higher
