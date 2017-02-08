class ExternalAttachment < ActiveRecord::Base
  belongs_to :container, :polymorphic => true
  belongs_to :author, :class_name => "User"
  validates_presence_of :url, :author
  validates_length_of :url, :maximum => 1024
  attr_protected :id

  # Returns an unsaved copy of the attachment
  def copy(attributes=nil)
    copy = self.class.new
    copy.attributes = self.attributes.dup.except("id", "downloads")
    copy.attributes = attributes if attributes
    copy
  end

  def validate_max_file_size
    if @temp_file && self.filesize > Setting.attachment_max_size.to_i.kilobytes
      errors.add(:base, l(:error_attachment_too_big, :max_size => Setting.attachment_max_size.to_i.kilobytes))
    end
  end

  def validate_file_extension
    if @temp_file
      extension = File.extname(filename)
      unless self.class.valid_extension?(extension)
        errors.add(:base, l(:error_attachment_extension_not_allowed, :extension => extension))
      end
    end
  end

  # Deletes the file from the file system if it's not referenced by other attachments
  def delete_from_disk
    if Attachment.where("disk_filename = ? AND id <> ?", disk_filename, id).empty?
      delete_from_disk!
    end
  end

  # Returns file's location on disk
  def diskfile
    File.join(self.class.storage_path, disk_directory.to_s, disk_filename.to_s)
  end

  def visible?(user=User.current)
    if container_id
      container && container.attachments_visible?(user)
    else
      author == user
    end
  end

  def deletable?(user=User.current)
    if container_id
      container && container.attachments_deletable?(user)
    else
      author == user
    end
  end

  def self.find_by_token(token)
    if token.to_s =~ /^(\d+)\.([0-9a-f]+)$/
      attachment_id, attachment_digest = $1, $2
      attachment = Attachment.where(:id => attachment_id, :digest => attachment_digest).first
      if attachment && attachment.container.nil?
        attachment
      end
    end
  end

  # Bulk attaches a set of files to an object
  #
  # Returns a Hash of the results:
  # :files => array of the attached files
  # :unsaved => array of the files that could not be attached
  def self.attach_files(obj, attachments)
    result = obj.save_attachments(attachments, User.current)
    obj.attach_saved_attachments
    result
  end

  # Updates the filename and description of a set of attachments
  # with the given hash of attributes. Returns true if all
  # attachments were updated.
  #
  # Example:
  #   Attachment.update_attachments(attachments, {
  #     4 => {:filename => 'foo'},
  #     7 => {:filename => 'bar', :description => 'file description'}
  #   })
  #
  def self.update_attachments(attachments, params)
    params = params.transform_keys {|key| key.to_i}

    saved = true
    transaction do
      attachments.each do |attachment|
        if p = params[attachment.id]
          attachment.filename = p[:filename] if p.key?(:filename)
          attachment.description = p[:description] if p.key?(:description)
          saved &&= attachment.save
        end
      end
      unless saved
        raise ActiveRecord::Rollback
      end
    end
    saved
  end

  # Returns true if the extension is allowed, otherwise false
  def self.valid_extension?(extension)
    extension = extension.downcase.sub(/\A\.+/, '')

    denied, allowed = [:attachment_extensions_denied, :attachment_extensions_allowed].map do |setting|
      Setting.send(setting).to_s.split(",").map {|s| s.strip.downcase.sub(/\A\.+/, '')}.reject(&:blank?)
    end
    if denied.present? && denied.include?(extension)
      return false
    end
    unless allowed.blank? || allowed.include?(extension)
      return false
    end
    true
  end

  private

  def sanitize_filename(value)
    # get only the filename, not the whole path
    just_filename = value.gsub(/\A.*(\\|\/)/m, '')

    # Finally, replace invalid characters with underscore
    just_filename.gsub(/[\/\?\%\*\:\|\"\'<>\n\r]+/, '_')
  end
end
