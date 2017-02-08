module ExternalAttachmentsHelper

  def link_to_external_attachments(container, options = {})
    # Options:
    # * :author -- author names are not displayed if set to false
    options.assert_valid_keys(:author)
    attachments = container.attachments.preload(:author).to_a
    if attachments.any?
      options = {
        :editable => container.attachments_editable?,
        :deletable => container.attachments_deletable?,
        :author => true
      }.merge(options)
      render :partial => 'attachments/links',
        :locals => {
          :container => container,
          :attachments => attachments,
          :options => options
        }
    end
  end

end
