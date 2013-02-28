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

colsize = 37
emptyrow = "<span>&nbsp;</span>"

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

#  if $("#position_bar_inited").text() == "false"
#    result = create_position_bar(nrow)
#    $("#position_bar").html(result)
#    $("#position_bar_inited").text("true")

#  if $("#result_panel_inited").text() == "false"
#    result = create_result_panel(nrow)
#    $("#result_panel").html(result)
#    $("#result_panel_inited").text("true")

  color_matching(seq, matchline, panelnum)

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

color_matching= (seq, matchline, panelnum) ->
  match_arr = matchline.split ""
  for i in [0..(match_arr.length-1)]
    if match_arr[i] is '*'
      $("\#panel_#{panelnum}_nuc_#{i}").addClass("nuc-matching")
    else
      $("\#panel_#{panelnum}_nuc_#{i}").addClass("panel_#{panelnum}_col")

copy_matching= () ->
  for i in [0..(matching_rows.length)]
    if not inserted_rows[i]
      $("#result_#{i}").html($("#panel_2_row_#{i}").html())

create_position_bar= (nrow) ->
  position_str = ""
  sum = 0
  curr_exon = 0
  for i in [0..(nrow)]
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
  for i in [0..(nrow-1)]
    control_str += "<div><span id=\"copy_#{panelnum}_#{i}\">\>\></div>"
  $("\#control_#{panelnum}").html(control_str)

  for i in [0..(nrow)]
    $("\#copy_#{panelnum}_#{i}").click ->
      curr_row = @id.replace /.*_/, ""
      console.log "#{@id} clicked, curr_row=#{curr_row}"
      $("#result_#{curr_row}").html($("\#panel_#{panelnum}_row_#{curr_row}").html())

create_and_set_delete_bar= (nrow, panelnum) ->
  control_str = ""
  for i in [0..(nrow)]
    control_str += "<div><span id=\"delete_4_#{i}\">x</span></div>"
  $("\#control_4").html(control_str)

  for i in [0..(nrow)]
    $("\#delete_4_#{i}").click ->
      curr_row = @id.replace /.*_/, ""
      console.log "#{@id} clicked, curr_row=#{curr_row}"
      $("#result_#{curr_row}").html(emptyrow)

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
  setSeq(seq3, 3, seqname3)

  result = create_position_bar(nuc_per_line.length-1)
  $("#position_bar").html(result)
  result = create_result_panel(nuc_per_line.length)
  $("#result_panel").html(result)

  copy_matching()

  create_and_set_delete_bar(nuc_per_line.length-1, 4)

  $("#save_txt").click =>
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