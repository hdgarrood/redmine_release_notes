class ReleaseNote < ActiveRecord::Base
  unloadable
  belongs_to :issue
  validates_presence_of :text, :issue_id
end
