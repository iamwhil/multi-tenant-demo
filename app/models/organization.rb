class Organization < ApplicationRecord

  has_many :users
  validates_uniqueness_of :name
  validates_uniqueness_of :subdomain


  def self.current_id=(id)
    Thread.current[:organization_id] = id
  end

  def self.current_id
    Thread.current[:organization_id]
  end

end
