module StaticPagesHelper
  def get_exon_str(exon)
    result = " "*(exon.end-exon.start)
    result
  end
end
