# Copyright © 2012  Harry Garrood
# This file is a part of redmine_release_notes.

# redmine_release_notes is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# redmine_release_notes is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with redmine_release_notes.  If not, see <http://www.gnu.org/licenses/>.

class ReleaseNote < ActiveRecord::Base
  unloadable
  belongs_to :issue

  def self.statuses
    %w(todo done not_required)
  end

  attr_accessible :text, :status

  validates_presence_of :issue
  validates_presence_of :text,
    :if => :done?,
    :message => I18n.t('release_notes.cant_be_blank_when_done')

  validates :status,
    :inclusion => { :in => statuses }

  before_validation(:on => :create) do
    self.status = 'todo' unless attribute_present?(:status)
  end

  def done?
    status == 'done'
  end
end
