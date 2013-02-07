class GlobalParamsController < ApplicationController
  # GET /global_params
  # GET /global_params.json
  def index
    @global_params = GlobalParam.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @global_params }
    end
  end

  # GET /global_params/1
  # GET /global_params/1.json
  def show
    @global_param = GlobalParam.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @global_param }
    end
  end

  # GET /global_params/new
  # GET /global_params/new.json
  def new
    @global_param = GlobalParam.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @global_param }
    end
  end

  # GET /global_params/1/edit
  def edit
    @global_param = GlobalParam.find(params[:id])
  end

  # POST /global_params
  # POST /global_params.json
  def create
    @global_param = GlobalParam.new(params[:global_param])

    respond_to do |format|
      if @global_param.save
        format.html { redirect_to @global_param, notice: 'Global param was successfully created.' }
        format.json { render json: @global_param, status: :created, location: @global_param }
      else
        format.html { render action: "new" }
        format.json { render json: @global_param.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /global_params/1
  # PUT /global_params/1.json
  def update
    @global_param = GlobalParam.find(params[:id])

    respond_to do |format|
      if @global_param.update_attributes(params[:global_param])
        format.html { redirect_to @global_param, notice: 'Global param was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @global_param.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /global_params/1
  # DELETE /global_params/1.json
  def destroy
    @global_param = GlobalParam.find(params[:id])
    @global_param.destroy

    respond_to do |format|
      format.html { redirect_to global_params_url }
      format.json { head :no_content }
    end
  end
end
