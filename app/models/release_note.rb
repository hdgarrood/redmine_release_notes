class ReleaseNote < ActiveRecord::Base
  unloadable
  belongs_to :issue
  validates_presence_of :text, :issue_id
  validates_length_of :text, :maximum => 2000, :message => "maximum length is 2000 characters"
end
