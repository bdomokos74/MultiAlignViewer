require 'multialign_annotator'

class StaticPagesController < ApplicationController
  def alignment
    data_dir = "/data/projects/AnalysisTools/projects/richter_cho/06_contract_MS1/data/multi"
    #aln_file = "actb_tcons_696_mmu.aln"

    aln_file = "actb_multi_696_consensus.aln"
    exon_gtf = "TCONS_00000696.gtf"
    seqid = "TCONS_00000696"

    aln = Bio::ClustalW::Report.new(File.read(File.join(data_dir, aln_file)))
    @match_line = aln.match_line
    @seq0 = wrap(aln.get_sequence(0).to_s)

    @seq1 = wrap(aln.get_sequence(1).to_s)
    @title = "Actb - TCONS000000696 vs MMU"

    gtf = Bio::GFF.new(File.open(File.join(data_dir, exon_gtf)))
    #exons = gtf.records.select { |rec| rec.attributes["transcript_id"].gsub("\"", "") == seqid }

    ref_seq = aln.alignment[seqid]
    @aln_len = ref_seq.length

    @exons = MultiAlignAnnotator.new().create_gapped_features(ref_seq, gtf.records)
    p @exons
  end

  def wrap(seq)
    col_size = 36
    wrapped = ""
    i = 0
    while i < seq.length
      j = i + col_size
      wrapped << seq[(i..j)] << "\n"
      i += col_size
    end
    return(wrapped)
  end
end
