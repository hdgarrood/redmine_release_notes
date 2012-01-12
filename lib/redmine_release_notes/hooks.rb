module RedmineReleaseNotes
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_show_description_bottom,
	          :partial => 'hooks/release_notes/view_issues_show_description_bottom'
  end
end