class ManageReception < ApplicationRecord
  belongs_to :userable, polymorphic: true
end
