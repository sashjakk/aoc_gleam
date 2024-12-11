import advent
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string

pub fn main() {
  let content = advent.read("./input/day_11.txt")

  let result_1 = advent.elapsed(fn() { part_1(content) })
  advent.print(day: 11, part: 1, result: result_1)

  let result_2 = advent.elapsed(fn() { part_2(content) })
  advent.print(day: 11, part: 2, result: result_2)
}

fn part_1(content: String) -> Int {
  let stones =
    content
    |> string.drop_end(1)
    |> string.split(" ")
    |> list.filter_map(int.parse)
    |> list.map(fn(it) { #(it, 1) })
    |> dict.from_list

  iterate(stones, 24)
  |> dict.values
  |> int.sum
}

fn part_2(content: String) -> Int {
  let stones =
    content
    |> string.drop_end(1)
    |> string.split(" ")
    |> list.filter_map(int.parse)
    |> list.map(fn(it) { #(it, 1) })
    |> dict.from_list

  iterate(stones, 74)
  |> dict.values
  |> int.sum
}

fn blink(stones: Dict(Int, Int)) {
  use acc, key, amount <- dict.fold(stones, dict.new())

  let digits = int.to_string(key)
  let is_even = digits |> string.length |> int.is_even

  let updates = case key, is_even {
    0, _ -> [#(1, amount)]
    _, True -> {
      let cut = string.length(digits) / 2

      [
        string.slice(digits, 0, cut),
        string.slice(digits, cut, string.length(digits)),
      ]
      |> list.filter_map(int.parse)
      |> list.map(fn(x) { #(x, amount) })
    }
    it, False -> [#(it * 2024, amount)]
  }

  use acc, #(key, value) <- list.fold(updates, acc)
  use existing <- dict.upsert(acc, key)
  case existing {
    Some(it) -> it + value
    None -> value
  }
}

fn iterate(stones: Dict(Int, Int), times: Int) {
  use acc, _ <- list.fold(list.range(0, times), stones)
  blink(acc)
}
