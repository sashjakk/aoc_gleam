import advent
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string

pub fn main() {
  let lines = advent.read_lines("./input/day_01.txt")

  let result_1 = advent.elapsed(fn() { part_1(lines) })
  advent.print(day: 1, part: 1, result: result_1)

  let result_2 = advent.elapsed(fn() { part_2(lines) })
  advent.print(day: 1, part: 2, result: result_2)
}

fn part_1(lines: List(String)) -> Int {
  let #(first, second) = parse_columns(lines)

  list.map2(
    first |> list.sort(int.compare),
    second |> list.sort(int.compare),
    fn(a, b) { int.absolute_value(a - b) },
  )
  |> int.sum
}

fn part_2(lines: List(String)) -> Int {
  let #(first, second) = parse_columns(lines)

  let table = {
    use acc, number <- list.fold(second, dict.new())
    use value <- dict.upsert(acc, number)
    case value {
      Some(amount) -> amount + 1
      None -> 1
    }
  }

  first
  |> list.map(fn(key) {
    case dict.get(table, key) {
      Ok(amount) -> key * amount
      _ -> 0
    }
  })
  |> int.sum
}

fn parse_columns(lines: List(String)) -> #(List(Int), List(Int)) {
  let line_to_ints = fn(line: String) {
    line
    |> string.split("   ")
    |> list.filter_map(int.parse)
  }

  let array_to_pair = fn(array: List(a)) {
    case array {
      [a, b] -> #(a, b) |> Ok
      _ -> Error(Nil)
    }
  }

  lines
  |> list.map(line_to_ints)
  |> list.filter_map(array_to_pair)
  |> list.unzip
}
