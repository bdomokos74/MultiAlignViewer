class SequencesController < ApplicationController
  def show
    data_dir = "/data/projects/AnalysisTools/projects/richter_cho/06_contract_MS1/data/multi"
    aln = "actb_tcons_696_mmu.aln"
    exon_gtf = "TCONS_00000696.gtf"
    seqid = "TCONS_00000696"

    aln = Bio::ClustalW::Report.new(File.read(File.join(data_dir, aln)))
    match_line = aln.match_line
    n = params[:id].to_i
    seq = aln.get_sequence(n).to_s
    seqname = aln.alignment.keys[n]
    p "param: #{params[:id]}"
    p @seq
    respond_to do |format|
      #format.html # show.html.erb
      format.json { render json: [seqname, seq, match_line].to_json }
    end
  end
end
