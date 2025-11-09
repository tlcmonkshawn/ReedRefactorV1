# Location Model
#
# Represents a physical store location.
# Locations can have multiple Booties associated with them.
#
# Locations support sub-location tracking (e.g., "Aisle 3", "Back Room") via
# the Bootie model's description or metadata fields.
class Location < FirestoreModel
  # Define attributes
  attribute :name, :string
  attribute :address, :string
  attribute :city, :string
  attribute :state, :string
  attribute :zip_code, :string
  attribute :phone_number, :string
  attribute :email, :string
  attribute :latitude, :decimal
  attribute :longitude, :decimal
  attribute :notes, :string
  attribute :active, :boolean, default: true

  # Validations
  validates :name, presence: true

  # Scopes
  def self.active
    where(:active, true).get
  end

  # Helper method to format full address string
  def full_address
    parts = [address, city, state, zip_code].compact.reject(&:blank?)
    parts.join(', ')
  end

  # Associations
  def booties
    Bootie.where(:location_id, id).get
  end
end
