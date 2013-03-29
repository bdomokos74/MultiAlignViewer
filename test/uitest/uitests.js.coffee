class Ui
  toint: (str) ->
    parseInt(str, 10)

test "hello test", 1, () ->
  u = new Ui()
  console.log u
  actual = u.toint("1")
  equal actual, 1

  a = []
  a.push ["A", 1]
  a.push [2, 3]
  console.log a