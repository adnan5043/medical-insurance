class Transaction < ApplicationRecord
    validates :file_id, uniqueness: true

end
