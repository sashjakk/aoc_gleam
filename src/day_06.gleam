import advent
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import table

pub fn main() {
  let content = advent.read("./input/day_06.txt")

  let result_1 = advent.elapsed(fn() { part_1(content) })
  advent.print(day: 6, part: 1, result: result_1)
  // let result_2 = advent.elapsed(fn() { part_2(content) })
  // advent.print(day: 6, part: 2, result: result_2)
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

  walk(grid, start, #(-1, 0), set.new())
  |> set.size
}

fn part_2(content: List(String)) -> Int {
  0
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
  visited: Set(#(Int, Int)),
) -> Set(#(Int, Int)) {
  let next = #(position.0 + direction.0, position.1 + direction.1)

  case dict.get(grid, next) {
    Ok(value) -> {
      case value {
        "#" -> walk(grid, position, rotate(direction), visited)
        _ -> walk(grid, next, direction, set.insert(visited, position))
      }
    }
    Error(_) -> set.insert(visited, position)
  }
}
