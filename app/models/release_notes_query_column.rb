class ReleaseNotesQueryColumn < QueryColumn
  def initialize
    super(:release_notes,
          :sortable => 'rn.status',
          :groupable => 'rn.status',
          :caption => 'release_notes.title_plural')
  end

  def value(object)
    I18n.t(object.release_note.status, :scope => 'release_notes.status')
  end
end
