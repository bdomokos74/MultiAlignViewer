class SequencesController < ApplicationController
  def initialize
    @data_dir = GlobalParam.find_by_key("data_dir").value
    current = GlobalParam.find_by_key("current_alignment").value
    alignment_record = Alignment.find_by_name(current)

    @aln_file = File.join(alignment_record.dir, "#{alignment_record.name}_compare.aln")
    @fa_file = @aln_file.gsub(/\.aln/, ".fa")
  end

  def show
    fasta_names = []
    Bio::FlatFile.foreach( File.join(@data_dir, @fa_file)) do |f|
      fasta_names << f.definition.gsub(/ .*$/, "")
    end

    aln = Bio::ClustalW::Report.new(File.read(File.join(@data_dir, @aln_file)))
    match_line = aln.match_line

    n = params[:id].to_i
    seqname = fasta_names[n]
    idx = aln.alignment.keys.index(seqname)

    seq = aln.get_sequence(idx).to_s

    p "param: #{params[:id]}"
    p @seq
    respond_to do |format|
      #format.html # show.html.erb
      format.json { render json: [seqname, seq, match_line].to_json }
    end
  end

  def index
    fasta_names = []
    Bio::FlatFile.foreach( File.join(@data_dir, @fa_file)) do |f|
      fasta_names << f.definition.gsub(/ .*$/, "")
    end

    aln = Bio::ClustalW::Report.new(File.read(File.join(@data_dir, @aln_file)))
    match_line = aln.match_line
    names = aln.alignment.keys

    n = names.length
    seqs = []
    (0..(n-1)).each do |i|
      seqs[i] = [fasta_names[i], aln.alignment[fasta_names[i]].to_s, match_line]
    end

    respond_to do |format|
      format.json { render json: seqs.to_json }
    end
  end
end
