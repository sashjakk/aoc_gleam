import advent
import coordinate
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string
import table

pub fn main() {
  let content = advent.read("./input/day_20.txt")

  let result_1 = advent.elapsed(fn() { part_1(content) })
  advent.print(day: 20, part: 1, result: result_1)

  let result_2 = advent.elapsed(fn() { part_2(content) })
  advent.print(day: 20, part: 2, result: result_2)
}

fn part_1(content: String) -> Int {
  solve(content, 2, 100)
}

fn part_2(content: String) -> Int {
  solve(content, 20, 100)
}

fn path(
  grid: table.Table,
  position: #(Int, Int),
  end: #(Int, Int),
  acc: Dict(#(Int, Int), Int),
) -> Dict(#(Int, Int), Int) {
  use <- bool.guard(position == end, acc)

  let neighbours =
    position
    |> coordinate.neighbours_4
    |> list.filter_map(fn(it) {
      case dict.get(acc, it), dict.get(grid, it) {
        Error(_), Ok(value) if value == "." || value == "S" || value == "E" ->
          Ok(it)
        _, _ -> Error(Nil)
      }
    })

  use acc, n <- list.fold(neighbours, acc)
  let assert Ok(price) = dict.get(acc, position)
  path(grid, n, end, dict.insert(acc, n, price + 1))
}

fn solve(content: String, cheat_range: Int, save: Int) {
  let grid =
    content
    |> string.to_graphemes
    |> table.from

  let assert [#(start, _), ..] =
    grid
    |> dict.filter(fn(_, value) { value == "S" })
    |> dict.to_list

  let assert [#(end, _), ..] =
    grid
    |> dict.filter(fn(_, value) { value == "E" })
    |> dict.to_list

  let route = path(grid, start, end, dict.from_list([#(start, 0)]))

  route
  |> dict.keys
  |> list.flat_map(fn(it) {
    {
      use acc, r <- list.fold(list.range(-cheat_range, cheat_range), [])
      use acc, c <- list.fold(list.range(-cheat_range, cheat_range), acc)
      [#(r, c), ..acc]
    }
    |> list.map(coordinate.add(it, _))
    |> list.filter(dict.has_key(route, _))
    |> list.filter(fn(point) { distance(point, it) <= cheat_range })
    |> list.filter_map(fn(point) {
      case dict.get(route, it), dict.get(route, point), dict.get(route, end) {
        Ok(curr), Ok(cheat), Ok(end) -> {
          let distance = distance(it, point)
          Ok(curr + distance + { end - cheat })
        }
        _, _, _ -> Error(Nil)
      }
    })
  })
  |> list.count(fn(cheat) {
    let assert Ok(price) = dict.get(route, end)
    price - cheat >= save
  })
}

fn distance(a: #(Int, Int), b: #(Int, Int)) {
  int.absolute_value(a.0 - b.0) + int.absolute_value(a.1 - b.1)
}
