import advent
import coordinate
import gleam/bool
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
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
  |> dict.fold(0, fn(acc, key, _) { acc + { 100 * key.0 + key.1 } })
}

fn part_2(content: String) -> Int {
  let #(map, moves) = case string.split(content, "\n\n") {
    [a, b] -> #(a, b)
    _ -> #("", "")
  }

  let map =
    map
    |> string.replace("#", "##")
    |> string.replace("O", "[]")
    |> string.replace(".", "..")
    |> string.replace("@", "@.")

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

  move2(grid, robot.0, moves)
  |> dict.filter(fn(_, value) { value == "[" })
  |> dict.fold(0, fn(acc, key, _) { acc + { 100 * key.0 + key.1 } })
}

fn move(
  grid: Dict(#(Int, Int), String),
  position: #(Int, Int),
  moves: List(#(Int, Int)),
) {
  grid
  |> dict.insert(position, "@")
  |> table.snapshot
  |> string.append("\n")
  |> io.println

  case moves {
    [step, ..rest] -> {
      let next = coordinate.add(position, step)
      case dict.get(grid, next) {
        Ok(symbol) -> {
          case symbol {
            "." -> move(grid, next, rest)
            "#" -> move(grid, position, rest)
            "O" -> {
              let boxes = collect_boxes(grid, next, step, [])
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

fn collect_boxes2(
  grid: Dict(#(Int, Int), String),
  position: #(Int, Int),
  direction: #(Int, Int),
  boxes: Set(#(Int, Int)),
) {
  use <- bool.guard(set.contains(boxes, position), boxes)

  case dict.get(grid, position) {
    Ok(value) if value == "[" || value == "]" -> {
      set.union(
        {
          let next_position = coordinate.add(position, direction)
          let next_boxes = set.insert(boxes, position)
          collect_boxes2(grid, next_position, direction, next_boxes)
        },
        {
          let next_position = case value {
            "[" -> coordinate.add(position, #(0, 1))
            "]" -> coordinate.add(position, #(0, -1))
            _ -> panic
          }

          let next_boxes = set.insert(boxes, position)
          collect_boxes2(grid, next_position, direction, next_boxes)
        },
      )
    }
    _ -> boxes
  }
}

fn move2(
  grid: Dict(#(Int, Int), String),
  position: #(Int, Int),
  moves: List(#(Int, Int)),
) {
  // grid
  // |> dict.insert(position, "@")
  // |> table.snapshot
  // |> string.append("\n")
  // |> io.println

  case moves {
    [step, ..rest] -> {
      let next = coordinate.add(position, step)
      case dict.get(grid, next) {
        Ok(symbol) -> {
          case symbol {
            "." -> move2(grid, next, rest)
            "#" -> move2(grid, position, rest)
            "[" | "]" -> {
              let boxes =
                collect_boxes2(grid, next, step, set.new())

              let #(next_grid, moved) = {
                use <- bool.guard(
                  when: {
                    boxes
                    |> set.to_list
                    |> list.map(coordinate.add(_, step))
                    |> list.filter_map(dict.get(grid, _))
                    |> list.any(fn(it) { it == "#" })
                  },
                  return: #(grid, False),
                )

                let transitioned =
                  boxes
                  |> set.to_list
                  |> list.filter_map(fn(it) {
                    case dict.get(grid, it) {
                      Ok(value) -> Ok(#(it, value))
                      _ -> Error(Nil)
                    }
                  })
                  |> list.map(fn(it) { #(coordinate.add(it.0, step), it.1) })
                  |> dict.from_list

                let deleted = set.fold(boxes, grid, fn(acc, key) {
                  dict.insert(acc, key, ".")
                })
                |> dict.insert(position, ".")

                #(
                  dict.fold(transitioned, deleted, dict.insert),
                  True,
                )
              }

              let next_position = case moved {
                True -> next
                False -> position
              }

              move2(next_grid, next_position, rest)
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
