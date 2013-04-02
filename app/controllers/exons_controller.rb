require 'multialign_annotator'
require 'json'

class ExonsController < ApplicationController

  def show
    data_dir = GlobalParam.find_by_key("data_dir").value
    current = GlobalParam.find_by_key("current_alignment").value
    alignment_record = Alignment.find_by_name(current)
    p "current aln: #{current}"

    #aln_filename = File.join(data_dir, alignment_record.dir, "#{alignment_record.name}_multi_2.aln")
    #aln = Bio::ClustalW::Report.new(aln_filename)

    gtf_filename = File.join(data_dir, alignment_record.dir, alignment_record.exon_gtf)
    gtf = Bio::GFF.new(File.open(gtf_filename))
    #ref_seq = aln.alignment[alignment_record.seq_name]

    records = gtf.records
    if alignment_record.reverse
      records.reverse!
    end
    p records
    exons = create_features(records)
    respond_to do |format|
      format.json { render json: exons.to_json }
    end
  end

  def create_features( features)
    start_pos = 0
    result = []
    features.each_with_index do |f, i|
      n = f.end.to_i - f.start.to_i
      if(n==0)
        next
      end
      gapped_feature = {:name => "exon_#{i+1}",
                        :start => start_pos,
                        :end => start_pos+n}
      result << gapped_feature
      start_pos = start_pos+n+1
    end
    return result
  end
end
