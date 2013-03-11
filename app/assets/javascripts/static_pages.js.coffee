# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$.ajaxSetup cache: false
matching_rows = []
inserted_rows = []
exons = []
exon_splits = []
seqname1 = ""
seqname2 = ""
seqname3 = ""
seq1 = ""
seq2 = ""
seq3 = ""
matchline = ""
nuc_per_line = []
start_codons=["ATG"]
stop_codons=["TAG", "TAA", "TGA"]
colsize = 37
emptyrow = "<span>&nbsp;</span>"
start_positions = [0, 0, 0, 0, 0]
pas1 = "AATAAA"
pas2 = "ATTAAA"
utr3_signals = ["TGTAA", pas1, pas2]
changes = []
searchBox = ""

getAln= (data) ->
  console.log "getAln called"
  seqname1 = data[0][0]
  seqname2 = data[1][0]
  seq1 = data[0][1]
  seq2 = data[1][1]
  if data.length >2
    seqname3 = data[2][0]
    seq3 = data[2][1]
  matchline = data[0][2]

getExons= (e) ->
  console.log "getExons called"
  exons = e

setSeq= (seq, panelnum, seqname) ->
  [result, nrow] = create_markup(seq, matchline, panelnum)
  $("\#panel_#{panelnum}").html(result)
  $("#rownum_var").text(nrow)

  i = 0
  while $("\#panel_#{panelnum}_nuc_#{i}") is undefined or $("\#panel_#{panelnum}_nuc_#{i}").text()=="-"
    i += 1
  start_positions[panelnum] = i
  console.log "setting start pos #{panelnum}: #{start_positions[panelnum]}"
  color_matching(matchline, panelnum)

  create_and_set_control_bar(nrow, panelnum)

  # set panel names
  $("\#seqname_#{panelnum}").html(seqname)

create_markup= (seq, matchline, panelnum) ->
  nrow = 0
  chars_in_row = 0
  result = "<div id=\"panel_#{panelnum}_row_0\">"
  for ch, index in seq.split ""
    result = result + "<span id=\"panel_#{panelnum}_nuc_#{index}\">#{ch}</span>"
    chars_in_row += 1
    if (chars_in_row % colsize is 0) or should_split_row(seq, matchline, index)
      if matchline[(index-chars_in_row+1)..index] == Array(chars_in_row+1).join("*")
        matching_rows[nrow] = true
      else
        matching_rows[nrow] = false
      if panelnum==1
        if seq[(index-chars_in_row+1)..index] == Array(chars_in_row+1).join("-")
          inserted_rows[nrow] = true
        else
          inserted_rows[nrow] = false
      if panelnum == 2
        if seq[(index-chars_in_row+1)..index] == Array(chars_in_row+1).join("-")
          inserted_rows[nrow] = true
      nuc_per_line[nrow] = chars_in_row
      nrow += 1
      result = result + "</div><div id=\"panel_#{panelnum}_row_#{nrow}\">"
      chars_in_row = 0
  result += "</div>"
  [result, nrow]

color_matching= (matchline, panelnum) ->
  match_arr = matchline.split ""
  for i in [0..(match_arr.length-1)]
    if match_arr[i] is '*'
      $("\#panel_#{panelnum}_nuc_#{i}").addClass("nuc-matching")
    else
      $("\#panel_#{panelnum}_nuc_#{i}").addClass("panel_#{panelnum}_col")

clear_colors= (tag) ->
  $("\##{tag} div span").removeClass()

color_codons= (tag, orf, panelnum) ->
  buffer = "   "
  n = matchline.length
  i = start_positions[panelnum]
  console.log "startpos: #{panelnum} => #{i}"
#  while $("\##{tag}_#{i}") is undefined or $("\##{tag}_#{i}").text()=="-"
#    i += 1
  i += orf-1
  pos = 1
  while i < n
    while $("\##{tag}_#{i}") is undefined or $("\##{tag}_#{i}").text()=="-"
      i += 1
    nuc = $("\##{tag}_#{i}").text()
    buffer = buffer[1]+buffer[2]+nuc
    if pos % 3 == 0
      if buffer in start_codons
        $("\##{tag}_#{i-2}").addClass("codon_start_col")
        $("\##{tag}_#{i-1}").addClass("codon_start_col")
        $("\##{tag}_#{i}").addClass("codon_start_col")
      if buffer in stop_codons
        $("\##{tag}_#{i-2}").addClass("codon_stop_col")
        $("\##{tag}_#{i-1}").addClass("codon_stop_col")
        $("\##{tag}_#{i}").addClass("codon_stop_col")
    i += 1
    pos += 1

color_signals= (tag, panelnum, sig_arr=utr3_signals, sig_class="signal_col") ->
  console.log sig_arr
  mlen = 0
  for s in sig_arr
    if s.length > mlen
      mlen = s.length
  buffer = ""
  posarr = []
  n = matchline.length
  i = start_positions[panelnum]
  console.log n
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

copy_matching= () ->
  for i in [0..(matching_rows.length)]
    if not inserted_rows[i]
      $("#result_#{i}").html(copy_row(2, i))
  tag = "result_nuc"
  i = 0
  while $("\##{tag}_#{i}") is undefined or $("\##{tag}_#{i}").text()=="-"
    i += 1
  start_positions[4] = i
  add_nuc_switcher()

copy_row= (panel, rownum) ->
  console.log "copy row called: #{panel}, #{rownum}"
  result = ""
  $("\#panel_#{panel}_row_#{rownum} span").each (i) ->
      id = $(this).attr("id").replace /.*nuc_/, ""
      nuc = $(this).text()
      result += "<span id=\"result_nuc_#{id}\">#{nuc}</span>"
  result

create_position_bar= (nrow) ->
  position_str = ""
  sum = 0
  curr_exon = 0
  for i in [0..(nrow+1)]
    position_str += "<div class=\"exon_bar\">#{sum}<span class=\"exon_#{curr_exon+1}\"> </span><span> </span></div>\n"
    sum += nuc_per_line[i]
    if sum > exons[curr_exon]["end"]
      curr_exon += 1
  position_str

create_result_panel= (nrow) ->
  result_panel = ""
  for i in [0..(nrow)]
    result_panel += "<div id=\"result_#{i}\">#{emptyrow}</div>"
  result_panel

create_and_set_control_bar= (nrow, panelnum) ->
  control_str = ""
  for i in [0..(nrow)]
    control_str += "<div><span id=\"copy_#{panelnum}_#{i}\">\>\></div>"
  $("\#control_#{panelnum}").html(control_str)

  for i in [0..(nrow)]
    $("\#copy_#{panelnum}_#{i}").click ->
      curr_row = @id.replace /.*_/, ""
      console.log "#{@id} clicked, curr_row=#{curr_row}"
      $("\#result_#{curr_row}").html(copy_row(panelnum, curr_row))
      add_nuc_switcher()

create_and_set_delete_bar= (nrow, panelnum) ->
  control_str = ""
  for i in [0..(nrow+1)]
    control_str += "<div><span id=\"delete_4_#{i}\">x</span></div>"
  $("\#control_4").html(control_str)

  for i in [0..(nrow+1)]
    $("\#delete_4_#{i}").click ->
      curr_row = @id.replace /.*_/, ""
      console.log "#{@id} clicked, curr_row=#{curr_row}"
      $("\#result_#{curr_row}").html("")

should_split_row= (seq, match, index) ->
  return( (match[index] == ' ' and match[(index+1)..(index+37)] == Array(38).join("*")) or
  (match[index] == '*' and match[(index+1)..(index+37)] == Array(38).join(" ")) or
  index in exon_splits
  )

create_exon_splits= () ->
  n = exons.length
  console.log "len: "+n
  i = 0
  while i < n
    exon_splits[i] = exons[i]["end"]
    i += 1

show_result_seq= () ->
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

add_nuc_switcher= () ->
  $("\#result_panel div span").each () ->
    $(this).click show_nuc_switcher

class SearchBox
  constructor: () ->
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

  clear: () =>
    $("\##{@target} div span").removeClass("search_col")

  search: () =>
    search_str = $("#search_input").val()
    console.log search_str
    color_signals(@tag, @panelnum, [search_str], "search_col")



highlight_menu= (target) ->
  console.log target
  $(target).siblings().removeClass()
  $(target).addClass("menusel_col")

show_nuc_switcher= (evt) ->
  console.log "switcher clicked"
  $("#nuc_switcher").removeClass("hidden")
  $("#nuc_switcher").addClass("visible")
  obj = evt.currentTarget
  console.log obj
#  tid = evt.target.attributes["id"]
  $("#switch_A").unbind("click")
  $("#switch_A").click ->
    console.log obj
    $(obj).text("A")
    $(obj).addClass("modified_col")
    changes.push([obj, "A"])
    $("#nuc_switcher").removeClass("visible")
    $("#nuc_switcher").addClass("hidden")
  $("#switch_T").unbind("click")
  $("#switch_T").click ->
    console.log obj
    $(obj).text("T")
    $(obj).addClass("modified_col")
    changes.push([obj, "T"])
    $("#nuc_switcher").removeClass("visible")
    $("#nuc_switcher").addClass("hidden")
  $("#switch_C").unbind("click")
  $("#switch_C").click ->
    $(obj).text("C")
    $(obj).addClass("modified_col")
    changes.push([obj, "C"])
    $("#nuc_switcher").removeClass("visible")
    $("#nuc_switcher").addClass("hidden")
  $("#switch_G").unbind("click")
  $("#switch_G").click (evt) ->
    $(obj).text("G")
    $(obj).addClass("modified_col")
    changes.push([obj, "G"])
    $("#nuc_switcher").removeClass("visible")
    $("#nuc_switcher").addClass("hidden")
  $("#switch_gap").unbind("click")
  $("#switch_gap").click (evt) ->
    $(obj).text("-")
    $(obj).addClass("modified_col")
    changes.push([obj, "-"])
    $("#nuc_switcher").removeClass("visible")
    $("#nuc_switcher").addClass("hidden")
  $("#switch_close").unbind("click")
  $("#switch_close").click (evt) ->
    $("#nuc_switcher").removeClass("visible")
    $("#nuc_switcher").addClass("hidden")

color_changes= ()->
  for c in changes
    $(c[0]).text(c[1])
    $(c[0]).addClass("modified_col")

$(document).ready ->
  $.ajax
    url: "/exons/0.json"
    success: (x) -> getExons(x)
    error: (data, txtstat, err) -> console.log err
    async: false

  $.ajax
    url: "/sequences.json"
    success: (x) -> getAln(x, 1, "#panel_1")
    error: (data, txtstat, err) -> console.log err
    async: false

  create_exon_splits()

  setSeq(seq1, 1, seqname1)
  setSeq(seq2, 2, seqname2)
  if seq3 != ""
    setSeq(seq3, 3, seqname3)

  result = create_position_bar(nuc_per_line.length-1)
  $("#position_bar").html(result)
  result = create_result_panel(nuc_per_line.length)
  $("#result_panel").html(result)

  copy_matching()


  create_and_set_delete_bar(nuc_per_line.length-1, 4)

  $("#save_txt").click =>
    show_result_seq()

  $("#orf1_result").click (evt) ->
    highlight_menu(evt.currentTarget)
    clear_colors("result_panel")
    color_codons("result_nuc", 1, 4)
    color_signals("result_nuc", 4)
    color_changes()
    console.log start_positions
  $("#orf2_result").click (evt) ->
    highlight_menu(evt.currentTarget)
    clear_colors("result_panel")
    color_codons("result_nuc", 2, 4)
    color_signals("result_nuc", 4)
    color_changes()
  $("#orf3_result").click (evt) ->
    highlight_menu(evt.currentTarget)
    clear_colors("result_panel")
    color_codons("result_nuc", 3, 4)
    color_signals("result_nuc", 4)
    color_changes()

  $("#orf1_col1").click (evt) ->
    highlight_menu(evt.currentTarget)
    clear_colors("panel_1")
    color_codons("panel_1_nuc", 1, 1)
    color_signals("panel_1_nuc", 1)
  $("#orf2_col1").click (evt)->
    highlight_menu(evt.currentTarget)
    clear_colors("panel_1")
    color_codons("panel_1_nuc", 2, 1)
    color_signals("panel_1_nuc", 1)
  $("#orf3_col1").click (evt)->
    highlight_menu(evt.currentTarget)
    clear_colors("panel_1")
    color_codons("panel_1_nuc", 3, 1)
    color_signals("panel_1_nuc", 1)

  $("#orf1_col2").click (evt) ->
    highlight_menu(evt.currentTarget)
    clear_colors("panel_2")
    color_codons("panel_2_nuc", 1, 2)
    color_signals("panel_2_nuc", 2)
  $("#orf2_col2").click (evt) ->
    highlight_menu(evt.currentTarget)
    clear_colors("panel_2")
    color_codons("panel_2_nuc", 2, 2)
    color_signals("panel_2_nuc", 2)
  $("#orf3_col2").click (evt) ->
    highlight_menu(evt.currentTarget)
    clear_colors("panel_2")
    color_codons("panel_2_nuc", 3, 2)
    color_signals("panel_2_nuc", 2)

  $("#orf1_col3").click (evt) ->
    highlight_menu(evt.currentTarget)
    clear_colors("panel_3")
    color_codons("panel_3_nuc", 1, 3)
    color_signals("panel_3_nuc", 3)
  $("#orf2_col3").click (evt) ->
    highlight_menu(evt.currentTarget)
    clear_colors("panel_3")
    color_codons("panel_3_nuc", 2, 3)
    color_signals("panel_3_nuc", 3)
  $("#orf3_col3").click (evt) ->
    highlight_menu(evt.currentTarget)
    clear_colors("panel_3")
    color_codons("panel_3_nuc", 3, 3)
    color_signals("panel_3_nuc", 3)

  $("#diff_color").click ->
    $("#menu_line td span").removeClass()
    clear_colors("panel_1")
    color_matching(matchline, 1)
    clear_colors("panel_2")
    color_matching(matchline, 2)
    clear_colors("panel_3")
    color_matching(matchline, 3)
    clear_colors("result_panel")

  add_nuc_switcher()
  searchBox = new SearchBox()


