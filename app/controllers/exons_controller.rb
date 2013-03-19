require 'multialign_annotator'
require 'json'

class ExonsController < ApplicationController

  def show
    config_json = File.read(File.join(ENV["HOME"], "multialn_cfg.json"))
    params = JSON.parse(config_json)

    aln = Bio::ClustalW::Report.new(File.read(File.join(params["data_dir"], params["aln_file"])))
    gtf = Bio::GFF.new(File.open(File.join(params["data_dir"], params["exon_gtf"])))
    ref_seq = aln.alignment[params["seqid"]]

    records = gtf.records
    if params["reverse"]
      records.reverse!
    end
    exons = MultiAlignAnnotator.new().create_features(records)
    respond_to do |format|
      format.json { render json: exons.to_json }
    end
  end
end
