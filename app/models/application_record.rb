class ApplicationRecord < ActiveRecord::Base
  include DfE::Analytics::Entities

  primary_abstract_class
end
