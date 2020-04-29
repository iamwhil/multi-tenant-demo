class User < ApplicationRecord

  belongs_to :organization
  default_scope { where(organization_id: Organization.current_id) }

end
