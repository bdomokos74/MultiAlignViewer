class InputFile < ActiveRecord::Base
  attr_accessible :alignment_id, :name, :file_type
  validates :alignment_id, presence: true
  belongs_to :alignment
end
