import advent
import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import table

pub fn main() {
  let content = advent.read("./input/day_06.txt")

  let result_1 = advent.elapsed(fn() { part_1(content) })
  advent.print(day: 6, part: 1, result: result_1)

  let result_2 = advent.elapsed(fn() { part_2(content) })
  advent.print(day: 6, part: 2, result: result_2)
}

fn part_1(content: String) -> Int {
  let grid =
    content
    |> string.to_graphemes
    |> table.from

  let start =
    grid
    |> dict.filter(fn(_, value) { value == "^" })
    |> dict.keys
    |> list.first
    |> result.unwrap(#(0, 0))

  walk(grid, start, #(-1, 0), dict.new())
  |> pair.second
  |> dict.keys
  |> list.length
}

fn part_2(content: String) -> Int {
  let grid =
    content
    |> string.to_graphemes
    |> table.from

  let start =
    grid
    |> dict.filter(fn(_, value) { value == "^" })
    |> dict.keys
    |> list.first
    |> result.unwrap(#(0, 0))

  let path =
    walk(grid, start, #(-1, 0), dict.new())
    |> pair.second
    |> dict.keys

  use acc, obstacle <- list.fold(path, 0)
  let next_grid = dict.insert(grid, obstacle, "#")
  let #(looping, _) = walk(next_grid, start, #(-1, 0), dict.new())
  case looping {
    False -> acc
    True -> acc + 1
  }
}

fn rotate(direction: #(Int, Int)) {
  case direction {
    #(-1, 0) -> #(0, 1)
    #(0, 1) -> #(1, 0)
    #(1, 0) -> #(0, -1)
    _ -> #(-1, 0)
  }
}

fn walk(
  grid: Dict(#(Int, Int), String),
  position: #(Int, Int),
  direction: #(Int, Int),
  visited: Dict(#(Int, Int), #(Int, Int)),
) {
  use <- bool.guard(
    when: case dict.get(visited, position) {
      Ok(it) -> it == direction
      Error(_) -> False
    },
    return: #(True, visited),
  )

  let next = #(position.0 + direction.0, position.1 + direction.1)

  case dict.get(grid, next) {
    Ok(value) -> {
      case value {
        "#" -> walk(grid, position, rotate(direction), visited)
        _ ->
          walk(grid, next, direction, dict.insert(visited, position, direction))
      }
    }
    Error(_) -> #(False, dict.insert(visited, position, direction))
  }
}
