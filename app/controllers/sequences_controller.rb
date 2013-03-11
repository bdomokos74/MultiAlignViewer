class SequencesController < ApplicationController
  def initialize
    config_json = File.read(File.join(ENV["HOME"], "multialn_cfg.json"))
    params = JSON.parse(config_json)
    @data_dir = params["data_dir"]
    @aln_file = params["aln_file"]
  end

  def show
    aln = Bio::ClustalW::Report.new(File.read(File.join(@data_dir, @aln_file)))
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

  def index
    aln = Bio::ClustalW::Report.new(File.read(File.join(@data_dir, @aln_file)))
    match_line = aln.match_line
    names = aln.alignment.keys
    n = names.length
    seqs = []
    (0..(n-1)).each do |i|
      seqs[i] = [names[i], aln.get_sequence(i).to_s, match_line]
    end

    respond_to do |format|
      format.json { render json: seqs.to_json }
    end
  end
end
