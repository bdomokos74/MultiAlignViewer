class SelectGeneController < ApplicationController
  def select
    gene_name = params[:id]
    p = GlobalParam.find_by_key("current_alignment")
    p.value = gene_name
    p.save
    redirect_to "/static_pages/alignment"
  end
end
