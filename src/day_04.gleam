import advent
import gleam/bool
import gleam/dict
import gleam/list
import gleam/string
import table

pub fn main() {
  let content = advent.read("./input/day_04.txt")

  let result_1 = advent.elapsed(fn() { part_1(content) })
  advent.print(day: 4, part: 1, result: result_1)

  let result_2 = advent.elapsed(fn() { part_2(content) })
  advent.print(day: 4, part: 2, result: result_2)
}

fn part_1(content: String) -> Int {
  let grid = content |> string.to_graphemes |> table.from

  use acc, key, value <- dict.fold(grid, 0)
  use <- bool.guard(when: value != "X", return: acc)

  let match =
    [
      [#(0, 0), #(0, 1), #(0, 2), #(0, 3)],
      [#(0, 0), #(0, -1), #(0, -2), #(0, -3)],
      [#(0, 0), #(1, 0), #(2, 0), #(3, 0)],
      [#(0, 0), #(-1, 0), #(-2, 0), #(-3, 0)],
      [#(0, 0), #(-1, -1), #(-2, -2), #(-3, -3)],
      [#(0, 0), #(1, 1), #(2, 2), #(3, 3)],
      [#(0, 0), #(-1, 1), #(-2, 2), #(-3, 3)],
      [#(0, 0), #(1, -1), #(2, -2), #(3, -3)],
    ]
    |> list.map(fn(delta) {
      delta
      |> list.map(fn(it) { { #(key.0 + it.0, key.1 + it.1) } })
      |> list.filter_map(dict.get(grid, _))
      |> string.join("")
    })
    |> list.count(fn(it) { it == "XMAS" })

  acc + match
}

fn part_2(content: String) -> Int {
  let grid = content |> string.to_graphemes |> table.from

  use acc, key, value <- dict.fold(grid, 0)
  use <- bool.guard(when: value != "A", return: acc)

  let match =
    [[#(-1, -1), #(0, 0), #(1, 1)], [#(-1, 1), #(0, 0), #(1, -1)]]
    |> list.map(fn(delta) {
      delta
      |> list.map(fn(it) { #(key.0 + it.0, key.1 + it.1) })
      |> list.filter_map(dict.get(grid, _))
      |> string.join("")
    })
    |> list.all(fn(it) { it == "MAS" || it == "SAM" })
    |> bool.to_int

  acc + match
}
