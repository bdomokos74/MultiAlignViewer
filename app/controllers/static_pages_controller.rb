require 'multialign_annotator'

class StaticPagesController < ApplicationController
  def alignment
    config_json = File.read(File.join(ENV["HOME"], "multialn_cfg.json"))
    params = JSON.parse(config_json)

    #aln = Bio::ClustalW::Report.new(File.read(File.join(params["data_dir"], params["aln_file"])))
    #@match_line = aln.match_line
    #@seq0 = wrap(aln.get_sequence(0).to_s)
    #
    #@seq1 = wrap(aln.get_sequence(1).to_s)
    @gene_name = params["gene_name"]

    #gtf = Bio::GFF.new(File.open(File.join(params["data_dir"], params["exon_gtf"])))
    #exons = gtf.records.select { |rec| rec.attributes["transcript_id"].gsub("\"", "") == seqid }

    #ref_seq = aln.alignment[params["seqid"]]
    #@aln_len = ref_seq.length
    #
    #@exons = MultiAlignAnnotator.new().create_gapped_features(ref_seq, gtf.records)
    #p @exons
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
