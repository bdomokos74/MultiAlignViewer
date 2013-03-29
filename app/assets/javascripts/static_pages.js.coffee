# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

exports = this
exports.changes = []
exports.cmd_history = []

exports.toint= (str)->
  parseInt(str, 10)


class SearchBox
  constructor: (@panel) ->
    console.log "searchbox constr called"
    @target = "result_panel"
    $("#search_txt_result").click (evt) =>
      @show(evt.currentTarget)
    $("#search_close").click (evt) =>
      @hide()
    $("#search_go").click (evt) =>
      @search()
    $("#search_clear").click (evt) =>
      @clear()

  show: (target) ->
      console.log "searchbox show called"+ target.id
      # TODO: find search target based on event target
      @target = "result_panel"
      @tag = "result_nuc"
      @panelnum = 4
      $("#search_box").removeClass("hidden")
      $("#search_box").addClass("visible")

  hide: () ->
    $("#search_box").removeClass("visible")
    $("#search_box").addClass("hidden")

  clear: () ->
    @panel.clear_colors("search_col")
    @panel.color_differences()

  search: () ->
    search_str = $("#search_input").val()
    console.log search_str
    @panel.color_signals([search_str], "search_col")

class UIPanel
  constructor: (@panelname, @panelnum, @seqname, @seq, @ui) ->
    @start_codons=["ATG"]
    @stop_codons=["TAG", "TAA", "TGA"]
    @pas1 = "AATAAA"
    @pas2 = "ATTAAA"
    @utr3_signals = ["TGTAA", @pas1, @pas2]
    @colsize = 37
    @nuc_per_line = []
    @match_per_line = []
    @emptyrow = "<span>&nbsp;</span>"

    @changes = []
    console.log "panel "+@panelnum+" created: "+@seqname

  initPanel: (exon_seq, matchline) ->
    console.log "panel"+@panelnum+"init: "+@panelname
    [result, nrow] = @create_markup( exon_seq, matchline)
    $("\##{@panelname}").html(result)
    $("#rownum_var").text(nrow)

    i = 0
    while $("\#panel_#{@panelnum}_nuc_#{i}") is undefined or $("\#panel_#{@panelnum}_nuc_#{i}").text()=="-"
      i += 1
    @start_position = i
    console.log "setting start pos #{@panelnum}: #{@start_position}"

    @create_and_set_control_bar(nrow)

    # set panel names
    $("\#seqname_#{@panelnum}").html(@seqname)

    @set_highlight_cbs()

  highlight_menu: (target) ->
    $(target).siblings().removeClass()
    $(target).addClass("menusel_col")

  set_highlight_cbs: ->
    $("\#orf1_col#{@panelnum}").click (evt) =>
      @highlight_menu(evt.currentTarget)
      @clear_colors()
      @color_signals(@utr3_signals)
      @color_codons(1)
      @color_changes()
    $("#orf2_col#{@panelnum}").click (evt)=>
      @highlight_menu(evt.currentTarget)
      @clear_colors()
      @color_signals(@utr3_signals)
      @color_codons(2)
      @color_changes()
    $("#orf3_col#{@panelnum}").click (evt)=>
      @highlight_menu(evt.currentTarget)
      @clear_colors()
      @color_signals(@utr3_signals)
      @color_codons(3)
      @color_changes()

  init_empty_panel: (nrow) ->
    result_panel = ""
    for i in [0..(nrow)]
      result_panel += "<div id=\"result_#{i}\">#{@emptyrow}</div>"
    $("\##{@panelname}").html(result_panel)

  create_markup: (exon_seq, matchline) ->
    nrow = 0
    chars_in_row = 0
    nuc_in_row = 0
    match_in_row = 0
    result = "<div id=\"panel_#{@panelnum}_row_0\">"
    exon_pos = 0

    for ch, index in @seq.split ""
      result = result + "<span id=\"panel_#{@panelnum}_nuc_#{index}\">#{ch}</span>"
      chars_in_row += 1

      if matchline[index] == "*"
        match_in_row += 1
      if ch!='-'
        nuc_in_row += 1
      if (chars_in_row % @colsize is 0) or @should_split_row(@seq, matchline, index, exon_pos)
        @nuc_per_line[nrow] = nuc_in_row
        @match_per_line[nrow] = match_in_row
        nrow += 1
        result = result + "</div><div id=\"panel_#{@panelnum}_row_#{nrow}\">"
        chars_in_row = 0
        nuc_in_row = 0
        match_in_row = 0
      if exon_seq[index] != '-'
        exon_pos += 1
    result += "</div>"
    [result, nrow+1]

  create_and_set_control_bar: (nrow) ->
    control_str = ""
    for i in [0..(nrow-1)]
      control_str += "<div><span id=\"copy_#{@panelnum}_#{i}\">\>\></div>"
    $("\#control_#{@panelnum}").html(control_str)
    for i in [0..(nrow-1)]
      $("\#copy_#{@panelnum}_#{i}").click (evt) =>
        curr_row = evt.currentTarget.id.replace /.*_/, ""
        console.log "#{evt.currentTarget.id} clicked, curr_row=#{curr_row}"
        $("\#result_#{curr_row}").html(@ui.copy_row(@panelnum, curr_row))
        @ui.add_nuc_switcher()
        exports.cmd_history.push ["copy", @panelnum, curr_row]

  color_codons: (orf) ->
    tag = @panelname+"_nuc"
    buffer = "   "
    n = @ui.matchline.length
    i = @start_position
    console.log "panel: #{@panelnum} => startpos: #{i}, orf= #{orf}"

    current_nuc = $("\##{tag}_#{i}").text()
    while i<n and ( current_nuc=="-" or current_nuc==" ")
      i = i+1
      current_nuc = $("\##{tag}_#{i}").text()

    if i < n
      i = i + ( orf-1 )
      console.log "tag: #{tag}, i=#{i}, n=#{n}, firstcodon: "+$("\##{tag}_#{i}").text()+$("\##{tag}_#{i+1}").text()+$("\##{tag}_#{i+2}").text()

      pos = 1
      while i < n
        current_nuc = $("\##{tag}_#{i}").text()

        while i<n and ( current_nuc=="" or current_nuc=="-" or current_nuc==" ")
          i = i+1
          current_nuc = $("\##{tag}_#{i}").text()
        buffer = buffer[1]+buffer[2]+current_nuc
        if pos % 3 == 0
          if buffer in @start_codons
            $("\##{tag}_#{i-2}").removeClass()
            $("\##{tag}_#{i-1}").removeClass()
            $("\##{tag}_#{i}").removeClass()

            $("\##{tag}_#{i-2}").addClass("codon_start_col")
            $("\##{tag}_#{i-1}").addClass("codon_start_col")
            $("\##{tag}_#{i}").addClass("codon_start_col")
          if buffer in @stop_codons
            $("\##{tag}_#{i-2}").removeClass()
            $("\##{tag}_#{i-1}").removeClass()
            $("\##{tag}_#{i}").removeClass()

            $("\##{tag}_#{i-2}").addClass("codon_stop_col")
            $("\##{tag}_#{i-1}").addClass("codon_stop_col")
            $("\##{tag}_#{i}").addClass("codon_stop_col")
        i += 1
        pos += 1
    console.log "end: i="+i+" n="+n+" buffer=["+buffer+"]"

  color_signals: (sig_arr, sig_class="signal_col") ->
    tag = @panelname+"_nuc"
    console.log sig_arr
    mlen = 0
    for s in sig_arr
      if s.length > mlen
        mlen = s.length
    buffer = ""
    posarr = []
    n = @ui.matchline.length
    i = @start_position
    while i < n
      if $("\##{tag}_#{i}") is undefined or $("\##{tag}_#{i}").text()=="-"
        i += 1
      else
        nuc = $("\##{tag}_#{i}").text()
        posarr.push(i)
        if posarr.length > mlen
          posarr.splice(0, 1)

        buffer = buffer + nuc
        if buffer.length > mlen
          buffer = buffer[1..100]

        #      console.log buffer
        for s in sig_arr
          startpos = mlen - s.length
          if buffer[startpos..100]== s
            #          console.log buffer
            posarr.splice(0, startpos)
            for j in posarr
              $("\##{tag}_#{j}").removeClass()
              $("\##{tag}_#{j}").addClass(sig_class)
            posarr = []
            buffer = ""
        i += 1

  clear_colors: (cl) ->
    console.log "\##{@panelname} div span"
    $("\##{@panelname} div span").removeClass(cl)

  should_split_row: (seq, match, index, exon_pos) ->
    return( (match[index] == ' ' and match[(index+1)..(index+37)] == Array(38).join("*")) or
    (match[index] == '*' and match[(index+1)..(index+37)] == Array(38).join(" ")) or
    exon_pos in ui.exon_splits
    )

  color_differences: () ->
    match_arr = @ui.matchline.split ""
    for i in [0..(match_arr.length-1)]
      if match_arr[i] is '*'
        $("\##{@panelname}_nuc_#{i}").addClass("nuc-matching")
      else
        $("\##{@panelname}_nuc_#{i}").addClass("panel_#{@panelnum}_col")

  color_changes: ()->
    for c in exports.changes
      $(c[0]).text(c[1])
      $(c[0]).addClass("modified_col")

class DiffUI
  constructor: () ->
    @exons = []
    @exon_splits = []
    @seqname1 = ""
    @seqname2 = ""
    @seqname3 = ""
    @seq1 = ""
    @seq2 = ""
    @seq3 = ""
    @matchline = ""

    @searchBox = ""

  initUI: () ->
    @create_exon_splits()
    seqname1 = alnData[0][0]
    seqname2 = alnData[1][0]
    seq1 = alnData[0][1]
    seq2 = alnData[1][1]
    if alnData.length > 2
      seqname3 = alnData[2][0]
      seq3 = alnData[2][1]
    @matchline = alnData[0][2]
    @exons = exonData

    @panel1 = new UIPanel("panel_1", 1, seqname1, seq1, this)
    @panel1.initPanel(seq1, @matchline)
    @panel2 = new UIPanel("panel_2", 2, seqname2, seq2, this)
    @panel2.initPanel(seq1, @matchline)
    if seq3 != ""
      @panel3 = new UIPanel("panel_3", 3, seqname3, seq3, this)
      @panel3.initPanel(seq1, @matchline)
    @result_panel = new UIPanel("result_panel", 4, "result", "", this)
    @result_panel.init_empty_panel(@panel1.nuc_per_line.length)

    @copy_matching()
    @panel1.color_differences(@matchline)
    @panel2.color_differences(@matchline)
    @panel3.color_differences(@matchline)
    @result_panel.color_differences(@matchline)

    @result_panel.set_highlight_cbs()

    result = @create_position_bar(@panel1.nuc_per_line.length)
    $("#position_bar").html(result)

    @create_and_set_delete_bar(@panel1.nuc_per_line.length, 4)

    #save vars for offline page
    $("#matchline").attr('val', @matchline)
    $("#start_pos_1").attr('val', @panel1.start_position)
    $("#start_pos_2").attr('val', @panel2.start_position)
    if @seq3 != ""
      $("#start_pos_3").attr('val', @panel3.start_position)
    $("#start_pos_4").attr('val', @result_panel.start_position)

    #restore
    @matchline = $("#matchline").attr('val')
    @panel1.start_position = exports.toint($("#start_pos_1").attr('val'))
    @panel2.start_position = exports.toint($("#start_pos_2").attr('val'))
    if @seq3 != ""
      @panel3.start_position = exports.toint($("#start_pos_3").attr('val'))
    @result_panel.start_position = exports.toint($("#start_pos_4").attr('val'))

    $("#save_txt").click =>
      @show_result_seq()

    $("#diff_color").click =>
      $("#menu_line td span").removeClass()
      @panel1.clear_colors()
      @panel1.color_differences(@matchline)
      @panel2.clear_colors()
      @panel2.color_differences(@matchline)
      @panel3.clear_colors()
      @panel3.color_differences(@matchline)
      @result_panel.clear_colors()
      @result_panel.color_differences(@matchline)
      @result_panel.color_changes()

    $("#save_changes").click =>
      console.log JSON.stringify(exports.cmd_history)

    # JSON.parse
    @add_nuc_switcher()
    @searchBox = new SearchBox(@result_panel)

  create_position_bar: (nrow) ->
    position_str = ""
    sum = 0
    curr_exon = 0

    for i in [0..(nrow)]
      position_str += "<div class=\"exon_bar\">#{sum+1}<span class=\"exon_#{curr_exon+1}\"> </span><span> </span></div>\n"
      sum += @panel1.nuc_per_line[i]
      if sum > @exons[curr_exon]["end"] and curr_exon < @exons.length-1
        curr_exon += 1
    position_str

  create_and_set_delete_bar: (nrow, panelnum) ->
    control_str = ""
    for i in [0..(nrow)]
      control_str += "<div><span id=\"delete_4_#{i}\">x</span></div>"
    $("\#control_4").html(control_str)

    for i in [0..(nrow)]
      $("\#delete_4_#{i}").click ->
        curr_row = @id.replace /.*_/, ""
        console.log "#{@id} clicked, curr_row=#{curr_row}"
        $("\#result_#{curr_row}").html("<span>&nbsp;</span>")

  copy_matching: () ->
    n = @panel1.nuc_per_line.length
    for i in [0..(n)]
      if @panel1.match_per_line[i] / @panel1.nuc_per_line[i] > 0.8
        $("#result_#{i}").html(@copy_row(1, i))
        console.log exports.cmd_history
        exports.cmd_history.push ["copy", 1, i]
    tag = @result_panel.panelname+"_nuc"
    i = 0
    while (i<@panel1.seq.length) and ($("\##{tag}_#{i}").text() == "" or $("\##{tag}_#{i}").text()=="-")
      i += 1
    @result_panel.start_position = i
    console.log "startpos: "+i+" membervar: "+@result_panel.start_position
    @add_nuc_switcher()

  copy_row: (panel, rownum) ->
    result = ""
    $("\#panel_#{panel}_row_#{rownum} span").each (i) ->
      id = $(this).attr("id").replace /.*nuc_/, ""
      nuc = $(this).text()
      result += "<span id=\"result_panel_nuc_#{id}\">#{nuc}</span>"
    result

  create_exon_splits: () ->
    n = @exons.length
    console.log "len: "+n
    i = 0
    while i < n
      exon_splits[i] = exons[i]["end"]
      i += 1

  show_result_seq: () ->
    console.log "save clicked"
    $("#result_box").removeClass("hidden")
    $("#result_box").addClass("visible")
    txt = $("#result_panel").text()
    txt = txt.replace /(\W+)/g, ""
    chars = txt.split ""
    res = "<div>"
    for i in [0..(chars.length-1)]
      res = res+chars[i]
      if (i+1) % 117 is 0
        res = res + "</div><div>"
    res = res + "</div><br/><br/><div id=\"close\">Close</div>"
    $("#result_nuc").html(res)
    $("#close").click ->
      $("#result_box").removeClass("visible")
      $("#result_box").addClass("hidden")

  add_nuc_switcher: () ->
    $("\#result_panel div span").each () ->
      $(this).click (evt) ->
        obj = evt.currentTarget
        console.log "switcher clicked: "+obj.id
        $("#nuc_switcher").removeClass("hidden")
        $("#nuc_switcher").addClass("visible")

        $("#switch_A").unbind("click")
        $("#switch_A").click ->
          $(obj).text("A")
          $(obj).addClass("modified_col")
          exports.changes.push([obj, "A"])
          exports.cmd_history.push(["change", obj.id, "A"])
          $("#nuc_switcher").removeClass("visible")
          $("#nuc_switcher").addClass("hidden")

        $("#switch_T").unbind("click")
        $("#switch_T").click ->
          $(obj).text("T")
          $(obj).addClass("modified_col")
          exports.changes.push([obj, "T"])
          exports.cmd_history.push(["change", obj.id, "T"])
          $("#nuc_switcher").removeClass("visible")
          $("#nuc_switcher").addClass("hidden")

        $("#switch_C").unbind("click")
        $("#switch_C").click ->
          $(obj).text("C")
          $(obj).addClass("modified_col")
          exports.changes.push([obj, "C"])
          exports.cmd_history.push(["change", obj.id, "C"])
          $("#nuc_switcher").removeClass("visible")
          $("#nuc_switcher").addClass("hidden")

        $("#switch_G").unbind("click")
        $("#switch_G").click (evt) ->
          $(obj).text("G")
          $(obj).addClass("modified_col")
          exports.changes.push([obj, "G"])
          exports.cmd_history.push(["change", obj.id, "G"])
          $("#nuc_switcher").removeClass("visible")
          $("#nuc_switcher").addClass("hidden")

        $("#switch_gap").unbind("click")
        $("#switch_gap").click (evt) ->
          $(obj).text("-")
          $(obj).addClass("modified_col")
          exports.changes.push([obj, "-"])
          exports.cmd_history.push(["change", obj.id, "-"])
          $("#nuc_switcher").removeClass("visible")
          $("#nuc_switcher").addClass("hidden")

        $("#switch_close").unbind("click")
        $("#switch_close").click (evt) ->
          $("#nuc_switcher").removeClass("visible")
          $("#nuc_switcher").addClass("hidden")

####################################################
# start
####################################################
ui = new DiffUI()

alnData = []
getAln= (data) ->
  console.log "getAln called"
  alnData = data
exonData = []
getExons= (data) ->
  console.log "getExons called"
  exonData = data

$(document).ready ->
  exports.changes = []
  exports.cmd_history = []

  $.ajaxSetup cache: false
  $.ajax
    url: "/exons/0.json"
    success: (data) -> getExons(data)
    error: (data, txtstat, err) -> console.log err
    async: false

  $.ajax
    url: "/sequences.json"
    success: (data) -> getAln(data)
    error: (data, txtstat, err) -> console.log err
    async: false

  ui.initUI()