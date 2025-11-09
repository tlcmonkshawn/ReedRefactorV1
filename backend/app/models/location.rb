# Location Model
#
# Represents a physical store location.
# Locations can have multiple Booties associated with them.
#
# Locations support sub-location tracking (e.g., "Aisle 3", "Back Room") via
# the Bootie model's description or metadata fields.
class Location < ApplicationRecord
  # Associations
  # Restrict deletion if location has Booties (prevents orphaned Booties)
  has_many :booties, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true

  # Scopes
  scope :active, -> { where(active: true) }  # Only active locations

  # Helper method to format full address string
  # Combines address, city, state, and zip_code into a single string
  def full_address
    parts = [address, city, state, zip_code].compact.reject(&:blank?)
    parts.join(', ')
  end
end

