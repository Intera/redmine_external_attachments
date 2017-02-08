class CreateExternalAttachments < ActiveRecord::Migration
  def change
    create_table :external_attachments do |t|
      t.text :url
      t.string :author_id
      t.integer :container_id
      t.string :container_type
      t.text :description
      t.timestamp :created_on
    end
  end
end
