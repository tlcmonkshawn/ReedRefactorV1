# FirestoreModel - Base class for all Firestore models
#
# This replaces ApplicationRecord and provides a Firestore-based ORM interface
# that mimics ActiveRecord patterns for easier migration
class FirestoreModel
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serialization
  include ActiveModel::Dirty

  class_attribute :collection_name
  class_attribute :firestore_client

  # Set default collection name based on class name
  def self.inherited(subclass)
    super
    subclass.collection_name = subclass.name.underscore.pluralize
    subclass.firestore_client = Rails.application.config.firestore
  end

  # Define attributes that will be stored in Firestore
  attribute :id, :string
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  # Class methods for querying
  class << self
    # Find a document by ID
    def find(id)
      return nil if id.blank?
      doc_ref = firestore_client.col(collection_name).doc(id)
      doc = doc_ref.get
      return nil unless doc.exists?

      new_from_document(doc)
    rescue => e
      Rails.logger.error "FirestoreModel.find error: #{e.message}"
      nil
    end

    # Find multiple documents by IDs
    def find_by_ids(ids)
      return [] if ids.empty?
      
      # Firestore doesn't support IN queries with document_id directly
      # Fetch each document individually
      ids.map { |id| find(id) }.compact
    end

    # Get all documents (with optional limit)
    def all(limit: nil)
      query = firestore_client.col(collection_name)
      query = query.limit(limit) if limit
      query.get.map { |doc| new_from_document(doc) }
    end

    # Query documents
    def where(field, operator = :==, value = nil)
      if value.nil? && operator != :==
        # where(field, value) - default to ==
        value = operator
        operator = :==
      end

      # Convert symbol operators to Firestore operators
      firestore_operator = case operator
      when :==, '=='
        '=='
      when :!=, '!='
        '!='
      when :<, '<'
        '<'
      when :<=, '<='
        '<='
      when :>, '>'
        '>'
      when :>=, '>='
        '>='
      when :in, 'in'
        'in'
      when :array_contains, 'array-contains'
        'array-contains'
      else
        '=='
      end

      query = firestore_client.col(collection_name).where(field, firestore_operator, value)
      QueryBuilder.new(self, query)
    end

    # Create a new document
    def create(attributes = {})
      model = new(attributes)
      model.save
      model
    end

    # Create a new document (raises on error)
    def create!(attributes = {})
      model = new(attributes)
      raise RecordInvalid.new(model) unless model.save
      model
    end

    # Check if document exists
    def exists?(id)
      doc_ref = firestore_client.col(collection_name).doc(id)
      doc_ref.get.exists?
    end

    # Count documents
    def count
      firestore_client.col(collection_name).get.count
    end

    # Create from Firestore document
    def new_from_document(doc)
      data = doc.data || {}
      data['id'] = doc.document_id
      new(data)
    end

    # Get collection reference
    def collection
      firestore_client.col(collection_name)
    end
  end

  # Callback support
  extend ActiveModel::Callbacks
  define_model_callbacks :save, :create, :update, :destroy, :validation

  # Instance methods
  def initialize(attributes = {})
    super
    @new_record = true
    @destroyed = false
    self.created_at ||= Time.current if respond_to?(:created_at=)
    self.updated_at ||= Time.current if respond_to?(:updated_at=)
  end

  # Save the document to Firestore
  def save
    run_callbacks :validation do
      return false unless valid?
    end

    now = Time.current
    self.updated_at = now
    self.created_at ||= now

    data = attributes_for_firestore

    if new_record?
      run_callbacks :create do
        run_callbacks :save do
          # Create new document
          if id.present?
            doc_ref = self.class.firestore_client.col(self.class.collection_name).doc(id)
          else
            doc_ref = self.class.firestore_client.col(self.class.collection_name).doc
            self.id = doc_ref.document_id
          end
          doc_ref.set(data)
          @new_record = false
        end
      end
    else
      run_callbacks :update do
        run_callbacks :save do
          # Update existing document
          doc_ref = self.class.firestore_client.col(self.class.collection_name).doc(id)
          doc_ref.update(data)
        end
      end
    end

    changes_applied
    true
  rescue => e
    errors.add(:base, "Failed to save: #{e.message}")
    false
  end

  # Save and raise on error
  def save!
    raise RecordInvalid.new(self) unless save
    true
  end

  # Update attributes
  def update(attributes = {})
    assign_attributes(attributes)
    save
  end

  # Update attributes and raise on error
  def update!(attributes = {})
    assign_attributes(attributes)
    save!
  end

  # Delete the document
  def destroy
    return false if new_record? || destroyed?

    run_callbacks :destroy do
      doc_ref = self.class.firestore_client.col(self.class.collection_name).doc(id)
      doc_ref.delete
      @destroyed = true
      true
    end
  rescue => e
    errors.add(:base, "Failed to destroy: #{e.message}")
    false
  end

  # Delete and raise on error
  def destroy!
    raise RecordNotDestroyed.new(self) unless destroy
    true
  end

  # Check if record is new
  def new_record?
    @new_record || id.blank?
  end

  # Check if record is persisted
  def persisted?
    !new_record? && !destroyed?
  end

  # Check if record is destroyed
  def destroyed?
    @destroyed == true
  end

  # Reload from Firestore
  def reload
    return self if new_record?

    doc = self.class.firestore_client.col(self.class.collection_name).doc(id).get
    raise DocumentNotFound.new("Document #{id} not found") unless doc.exists?

    data = doc.data || {}
    data['id'] = doc.document_id
    assign_attributes(data)
    @new_record = false
    @destroyed = false
    changes_applied
    self
  end

  # Get document reference
  def document_ref
    return nil if new_record?
    self.class.firestore_client.col(self.class.collection_name).doc(id)
  end

  private

  # Convert attributes to Firestore-compatible hash
  def attributes_for_firestore
    attrs = {}
    attribute_names.each do |name|
      value = public_send(name)
      next if value.nil? && name != 'id' # Skip nil values except id

      # Convert to Firestore-compatible types
      attrs[name] = convert_value_for_firestore(value)
    end
    attrs
  end

  # Convert Ruby values to Firestore-compatible types
  def convert_value_for_firestore(value)
    case value
    when Time, DateTime
      value.utc
    when Date
      value.to_time.utc
    when Array
      value.map { |v| convert_value_for_firestore(v) }
    when Hash
      value.transform_values { |v| convert_value_for_firestore(v) }
    else
      value
    end
  end

  # Query builder class for chaining queries
  class QueryBuilder
    def initialize(model_class, query)
      @model_class = model_class
      @query = query
    end

    def where(field, operator = :==, value = nil)
      if value.nil? && operator != :==
        value = operator
        operator = :==
      end
      @query = @query.where(field, operator, value)
      self
    end

    def order(field, direction = :asc)
      @query = @query.order(field, direction)
      self
    end

    def limit(count)
      @query = @query.limit(count)
      self
    end

    def offset(count)
      @query = @query.offset(count)
      self
    end

    def get
      @query.get.map { |doc| @model_class.new_from_document(doc) }
    end

    def first
      docs = limit(1).get
      docs.first
    end

    def count
      @query.get.count
    end

    def exists?
      limit(1).get.any?
    end
  end

  # Custom exceptions
  class RecordInvalid < StandardError
    attr_reader :record
    def initialize(record)
      @record = record
      super("Validation failed: #{record.errors.full_messages.join(', ')}")
    end
  end

  class RecordNotDestroyed < StandardError
    attr_reader :record
    def initialize(record)
      @record = record
      super("Record could not be destroyed")
    end
  end

  class DocumentNotFound < StandardError; end
end

