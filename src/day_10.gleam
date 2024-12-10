import advent
import coordinate
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import table

pub fn main() {
  let content = advent.read("./input/day_10.txt")

  let result_1 = advent.elapsed(fn() { part_1(content) })
  advent.print(day: 10, part: 1, result: result_1)

  let result_2 = advent.elapsed(fn() { part_2(content) })
  advent.print(day: 10, part: 2, result: result_2)
}

fn part_1(content: String) -> Int {
  let #(map, heads) =
    content
    |> string.to_graphemes
    |> parse

  heads
  |> list.map(fn(trailhead) {
    walk(map, trailhead)
    |> list.unique
    |> list.length
  })
  |> int.sum
}

fn part_2(content: String) -> Int {
  let #(map, heads) =
    content
    |> string.to_graphemes
    |> parse

  heads
  |> list.map(fn(trailhead) {
    walk(map, trailhead)
    |> list.length
  })
  |> int.sum
}

fn parse(content: List(String)) {
  let map =
    content
    |> table.from
    |> dict.filter(fn(_, value) { value != { "." } })
    |> dict.map_values(fn(_, value) { value |> int.parse |> result.unwrap(0) })

  let heads =
    map
    |> dict.filter(fn(_, value) { value == 0 })
    |> dict.to_list

  #(map, heads)
}

const directions = [#(0, 1), #(1, 0), #(0, -1), #(-1, 0)]

fn walk(map: Dict(#(Int, Int), Int), current: #(#(Int, Int), Int)) {
  case current {
    #(_, value) if value == 9 -> [current]
    #(position, value) ->
      directions
      |> list.map(coordinate.add(position, _))
      |> list.filter_map(fn(it) {
        map
        |> dict.get(it)
        |> result.map(fn(value) { #(it, value) })
      })
      |> list.filter(fn(it) { it.1 - value == 1 })
      |> list.flat_map(walk(map, _))
  }
}
