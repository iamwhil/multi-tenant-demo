class CreateOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations do |t|
      t.text :name, unique: true, index: true
      t.string :subdomain, unique: true, index: true
      t.timestamps
    end
  end
end
