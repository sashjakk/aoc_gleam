import advent
import coordinate
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import table

pub fn main() {
  let content = advent.read("./input/day_08.txt")

  let result_1 = advent.elapsed(fn() { part_1(content) })
  advent.print(day: 8, part: 1, result: result_1)

  let result_2 = advent.elapsed(fn() { part_2(content) })
  advent.print(day: 8, part: 2, result: result_2)
}

fn part_1(content: String) -> Int {
  use line, bounds <- solve(content)
  let #(start, end) = line

  let distance = coordinate.subtract(end, start)

  [coordinate.subtract(start, distance), coordinate.add(end, distance)]
  |> list.filter(coordinate.in_range(_, #(0, 0), bounds))
}

fn part_2(content: String) -> Int {
  use line, bounds <- solve(content)
  let #(start, end) = line

  let forward = coordinate.subtract(end, start)
  let backward = coordinate.subtract(start, end)

  list.flatten([
    propagate(start, forward, bounds, []),
    propagate(start, backward, bounds, []),
  ])
}

fn group(grid: Dict(#(Int, Int), String)) {
  use acc, key, value <- dict.fold(grid, dict.new())
  dict.upsert(acc, value, fn(existing) {
    case existing {
      Some(items) -> [key, ..items]
      None -> [key]
    }
  })
}

fn propagate(
  point: #(Int, Int),
  distance: #(Int, Int),
  bounds: #(Int, Int),
  acc: List(#(Int, Int)),
) {
  let next = coordinate.subtract(point, distance)
  let in_range = next |> coordinate.in_range(#(0, 0), bounds)
  case in_range {
    True -> propagate(next, distance, bounds, [point, next, ..acc])
    False -> acc
  }
}

type Line =
  #(#(Int, Int), #(Int, Int))

fn solve(
  content: String,
  antinodes: fn(Line, #(Int, Int)) -> List(#(Int, Int)),
) {
  let grid = content |> string.to_graphemes |> table.from
  let antenas = grid |> group |> dict.drop(["."])

  let bounds =
    grid
    |> dict.keys
    |> list.fold(#(0, 0), fn(acc, position) {
      #(int.max(acc.0, position.0), int.max(acc.1, position.1))
    })

  antenas
  |> dict.values
  |> list.flat_map(fn(group) {
    group
    |> list.combination_pairs
    |> list.flat_map(antinodes(_, bounds))
  })
  |> list.unique
  |> list.length
}
