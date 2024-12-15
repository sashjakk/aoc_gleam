import advent
import coordinate
import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string
import table

pub fn main() {
  let content = advent.read("./input/day_15.txt")

  let result_1 = advent.elapsed(fn() { part_1(content) })
  advent.print(day: 15, part: 1, result: result_1)

  let result_2 = advent.elapsed(fn() { part_2(content) })
  advent.print(day: 15, part: 2, result: result_2)
}

fn part_1(content: String) -> Int {
  let #(map, moves) = case string.split(content, "\n\n") {
    [a, b] -> #(a, b)
    _ -> #("", "")
  }

  let grid =
    map
    |> string.to_graphemes
    |> table.from

  let robot =
    grid
    |> dict.filter(fn(_, value) { value == "@" })
    |> dict.to_list
    |> list.first
    |> result.unwrap(#(#(0, 0), "@"))

  let grid = grid |> dict.insert(robot.0, ".")

  let moves =
    moves
    |> string.to_graphemes
    |> list.filter_map(fn(it) {
      case it {
        "<" -> Ok(#(0, -1))
        ">" -> Ok(#(0, 1))
        "^" -> Ok(#(-1, 0))
        "v" -> Ok(#(1, 0))
        _ -> Error(Nil)
      }
    })

  move(grid, robot.0, moves)
  |> dict.filter(fn(_, value) { value == "O" })
  |> dict.fold(0, fn(acc, key, _) {
    acc + { 100 * key.0 + key.1 }
  })
}

fn part_2(content: String) -> Int {
  0
}

fn move(
  grid: Dict(#(Int, Int), String),
  position: #(Int, Int),
  moves: List(#(Int, Int)),
) {
  // grid
  // |> dict.insert(position, "@")
  // |> snapshot(0, 0, "")
  // |> io.println

  case moves {
    [step, ..rest] -> {
      let next = coordinate.add(position, step)
      case dict.get(grid, next) {
        Ok(symbol) -> {
          case symbol {
            "." -> move(grid, next, rest)
            "#" -> move(grid, position, rest)
            "O" -> {
              let boxes =
                collect_boxes(grid, next, step, [])
                // |> io.debug

              let #(next_grid, moved) = {
                use #(acc, moved), box <- list.fold(boxes, #(grid, False))
                let neighbour = coordinate.add(box, step)
                case dict.get(acc, neighbour) {
                  Ok(symbol) if symbol == "." -> {
                    #(
                      acc
                        |> dict.insert(box, ".")
                        |> dict.insert(neighbour, "O"),
                      True,
                    )
                  }

                  _ -> #(acc, moved)
                }
              }

              let next_position = case moved {
                True -> next
                False -> position
              }

              move(next_grid, next_position, rest)
            }
            _ -> panic
          }
        }
        Error(_) -> grid
      }
    }
    _ -> grid
  }
}

fn collect_boxes(
  grid: Dict(#(Int, Int), String),
  position: #(Int, Int),
  direction: #(Int, Int),
  boxes: List(#(Int, Int)),
) {
  case dict.get(grid, position) {
    Ok(value) if value == "O" -> {
      let next_position = coordinate.add(position, direction)
      let next_boxes = [position, ..boxes]
      collect_boxes(grid, next_position, direction, next_boxes)
    }
    _ -> boxes
  }
}

fn snapshot(grid: Dict(#(Int, Int), String), row: Int, column: Int, acc: String) {
  use <- bool.guard(
    when: grid
      |> dict.keys
      |> list.is_empty,
    return: acc,
  )

  case dict.get(grid, #(row, column)) {
    Ok(key) -> {
      let next_grid = grid |> dict.delete(#(row, column))
      snapshot(next_grid, row, column + 1, acc <> key)
    }
    Error(_) -> snapshot(grid, row + 1, 0, acc <> "\n")
  }
}
