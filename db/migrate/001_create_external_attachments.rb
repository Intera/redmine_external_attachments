class CreateExternalAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :external_attachments do |t|
      t.text :url
      t.string :author_id
      t.integer :container_id
      t.integer :container_type
      t.text :description
    end
  end
end
