class Alignment < ActiveRecord::Base
  attr_accessible :user_changes, :dir, :exon_gtf, :name, :reverse, :seq_name
  has_many :input_file, dependent: :destroy
end
