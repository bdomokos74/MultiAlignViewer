require 'multialign_annotator'

class ExonsController < ApplicationController

  def show
    data_dir = "/data/projects/AnalysisTools/projects/richter_cho/06_contract_MS1/data/multi"
    aln_file = "actb_tcons_696_mmu.aln"
    exon_gtf = "TCONS_00000696.gtf"
    seqid = "TCONS_00000696"

    aln = Bio::ClustalW::Report.new(File.read(File.join(data_dir, aln_file)))
    gtf = Bio::GFF.new(File.open(File.join(data_dir, exon_gtf)))
    ref_seq = aln.alignment[seqid]

    exons = MultiAlignAnnotator.new().create_gapped_features(ref_seq, gtf.records)
    respond_to do |format|
      format.json { render json: exons.to_json }
    end
  end
end
