module StaticPagesHelper
  def get_exon_str(exon)
    result = " "*(exon['end'].to_i-exon['start'].to_i)
    result
  end
end
