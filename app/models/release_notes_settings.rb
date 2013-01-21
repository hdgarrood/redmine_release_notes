# for validating the plugin's settings only
class ReleaseNotesSettings
  include ActiveModel::Validations

  # to be valid:
  validate do
    custom_field = IssueCustomField.find(custom_field_id)
    if custom_field
      %w(not_required todo done).map{|s| "field_value_#{s}"}.each do |key|
        val = send(key)
        # each of the given values must be valid possible values
        unless custom_field.possible_values.include?(key)
          errors.add(:base,
                     t('release_notes.config.value_not_exist', val))
        end
      end
    else
    # its custom_field_id must reference an existing IssueCustomField
      errors.add(:base, t('release_notes.config.custom_field_not_exist'))
    end

    unless true # TODO
      # the referenced default generation format must exist
      errors.add(:base, t('release_notes.config.format_not_exist'))
    end
  end

  # public constructor method is +find+ instead of +new+
  class << self
    private :new
    def find
      instance = new
      instance.update(Setting.plugin_redmine_release_notes)
      instance
    end

    # used in init.rb; if no record in settings table exists. Obviously this
    # won't work but that doesn't matter -- we just prompt admins to configure
    # it.
    def defaults
      {
        :custom_field_id => 0,
        :field_value_done => '',
        :field_value_todo => '',
        :field_value_not_required => '',
        :default_generation_format => 'HTML'
      }
    end
  end

  # the settings which we allow people to configure
  KEYS = %w(custom_field_id field_value_done field_value_todo
    field_value_not_required default_generation_format).map(&:to_sym)

  attr_accessor(*KEYS)

  # allows updating the object; designed to be used with the params object in
  # controllers
  def update(attrs = {})
    attrs.each {|k, v| send(:"#{k}=", v) }
  end

  def save
    if valid?
      Setting.plugin_redmine_release_notes = to_h
      true
    else
      false
    end
  end

  private
  # converts this instance to a hash; needed so that we can save
  def to_h
    # i love ruby
    Hash[self.class::KEYS.map { |k| [k, send(k)] } ]
  end
end
