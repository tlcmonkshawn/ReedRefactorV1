# ApplicationRecord - Base class for all ActiveRecord models
#
# This is the base class for all models in the application.
# It provides a single point of configuration for ActiveRecord behavior.
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end

