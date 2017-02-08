require "redmine"
require File.dirname(__FILE__) + "/app/helpers/external_attachments_helper"
require_dependency "redmine_external_attachments/hooks"

require File.dirname(__FILE__) + '/lib/redmine_external_attachments/acts_as_external_attachable'
ActiveRecord::Base.send(:include, Redmine::Acts::ExternalAttachable)

Redmine::Plugin.register :redmine_external_attachments do
  name "external attachments"
  author "intera gmbh"
  author_url "https://github.com/intera"
  description "adds a new type of file attachment for urls that are not uploaded"
  version "1.0.0"
end

Rails.configuration.to_prepare do
  # "to_prepare" is a rails callback that is called at a stage where redmine plugins and redmine code has been loaded.
  RedmineExternalAttachments::IssuePatch.install
end
