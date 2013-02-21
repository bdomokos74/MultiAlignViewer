# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


$.ajaxSetup cache: false
matching_rows = []
colsize = 37
emptyrow = "<span>&nbsp;</span>"

setSeq= (data, panelnum) ->
    console.log "setSeq called"
    seq = data[1]
    seqname = data[0]
    matchline = data[2]
    target = "\#panel_#{panelnum}"

    [result, nrow] = create_markup(seq, matchline, panelnum)
    $(target).html(result)
    $("#rownum_var").text(nrow)

    if $("#position_bar_inited").text() == "false"
      result = create_position_bar(nrow)
      $("#position_bar").html(result)
      $("#position_bar_inited").text("true")

    if $("#result_panel_inited").text() == "false"
      result = create_result_panel(nrow)
      $("#result_panel").html(result)
      $("#result_panel_inited").text("true")

    color_matching(seq, matchline, panelnum)

    # create control bars
    control_str = ""
    for i in [0..(nrow-1)]
      control_str += "<div><span id=\"copy_#{panelnum}_#{i}\">\>\></div>"
    $("\#control_#{panelnum}").html(control_str)

    for i in [0..(nrow-1)]
      $("\#copy_#{panelnum}_#{i}").click ->
        curr_row = @id.replace /.*_/, ""
        console.log "#{@id} clicked, curr_row=#{curr_row}"
        $("#result_#{curr_row}").html($("\#panel_#{panelnum}_row_#{curr_row}").html())

    # set panel names
    $("\#seqname_#{panelnum}").html(seqname)

    copy_matching()

create_markup= (seq, matchline, panelnum) ->
  nrow = 0
  chars_in_row = 0
  result = "<div id=\"panel_#{panelnum}_row_0\">"
  for ch, index in seq.split ""
    result = result + "<span id=\"panel_#{panelnum}_nuc_#{index}\">#{ch}</span>"
    chars_in_row += 1
    if (chars_in_row % colsize is 0) or should_split_row(seq, matchline, index)
      if matchline[(index-chars_in_row+1)..index] ==Array(chars_in_row+1).join("*")
        matching_rows[nrow] = true
      else
        matching_rows[nrow] = false
      result = result + "</div><div id=\"panel_#{panelnum}_row_#{nrow}\">"
      nrow += 1
      chars_in_row = 0
  result += "</div>"
  [result, nrow]

color_matching= (seq, matchline, panelnum) ->
  match_arr = matchline.split ""
  for i in [0..(match_arr.length-1)]
    if match_arr[i] is '*'
      $("\#panel_#{panelnum}_nuc_#{i}").addClass("nuc-matching")

copy_matching= () ->
  for i in [0..(matching_rows.length-1)]
    if matching_rows[i]
      $("#result_#{i}").html($("#panel_1_row_#{i}").html())

create_position_bar= (nrow) ->
  position_str = ""
  for i in [0..(nrow)]
    position_str += "<div>#{i*colsize}</div>\n"
  position_str

create_result_panel= (nrow) ->
  result_panel = ""
  for i in [0..(nrow)]
    result_panel += "<div id=\"result_#{i}\">#{emptyrow}</div>"
  result_panel


should_split_row= (seq, match, index) ->
  return( (match[index] == ' ' and match[(index+1)..(index+37)] == Array(38).join("*")) or
    (match[index] == '*' and match[(index+1)..(index+37)] == Array(38).join(" "))
    )

$(document).ready ->
    $.ajax
      url: "/sequences/0.json"
      success: (x) -> setSeq(x, 1, "#panel_1")
      error: (data, txtstat, err) -> console.log err
    $.ajax
      url: "/sequences/1.json"
      success: (x) -> setSeq(x, 2, "#panel_2")
      error: (data, txtstat, err) -> console.log err

