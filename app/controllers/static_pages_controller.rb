class StaticPagesController < ApplicationController
  def alignment
    data_dir = "/Users/bds/projects/current/rails_projects/first_project/genome_data"
    aln = Bio::ClustalW::Report.new(File.read(data_dir+'/actb_multi.aln'))
    @match_line = aln.match_line[0..80]
    @seq0 = aln.get_sequence(0).to_s[0..80]
    @seq1 = aln.get_sequence(1).to_s[0..80]
  end
end
