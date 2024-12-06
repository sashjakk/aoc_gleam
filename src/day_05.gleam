import advent
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/order
import gleam/pair
import gleam/result
import gleam/string

pub fn main() {
  let content = advent.read_lines("./input/day_05.txt")

  let result_1 = advent.elapsed(fn() { part_1(content) })
  advent.print(day: 5, part: 1, result: result_1)

  let result_2 = advent.elapsed(fn() { part_2(content) })
  advent.print(day: 5, part: 2, result: result_2)
}

fn part_1(content: List(String)) -> Int {
  let #(rules, manuals) = parse(content)

  use acc, manual <- list.fold(manuals, 0)
  let sorted = list.sort(manual, sort_with(rules))
  case manual == sorted {
    False -> acc
    True ->
      {
        sorted
        |> list.split(list.length(sorted) / 2)
        |> pair.second
        |> list.first
        |> result.unwrap(0)
      }
      + acc
  }
}

fn part_2(content: List(String)) -> Int {
  let #(rules, manuals) = parse(content)

  use acc, manual <- list.fold(manuals, 0)
  let sorted = list.sort(manual, sort_with(rules))
  case manual == sorted {
    True -> acc
    False ->
      {
        sorted
        |> list.split(list.length(sorted) / 2)
        |> pair.second
        |> list.first
        |> result.unwrap(0)
      }
      + acc
  }
}

fn parse(content: List(String)) {
  let #(rules, manuals) =
    content
    |> list.partition(string.contains(_, "|"))

  let rules = {
    use acc, rule <- list.fold(rules, dict.new())

    let numbers =
      rule
      |> string.split("|")
      |> list.filter_map(int.parse)

    case numbers {
      [a, b] ->
        dict.upsert(acc, a, fn(existing) {
          case existing {
            Some(values) -> [b, ..values]
            None -> [b]
          }
        })
      _ -> acc
    }
  }

  let manuals = {
    use line <- list.map(manuals)
    line
    |> string.split(",")
    |> list.filter_map(int.parse)
  }

  #(rules, manuals)
}

fn sort_with(rules: Dict(Int, List(Int))) {
  fn(a, b) {
    use <- bool.guard(
      when: rules
        |> dict.get(b)
        |> result.map(list.contains(_, a))
        |> result.unwrap(False),
      return: order.Gt,
    )

    use <- bool.guard(
      when: rules
        |> dict.get(a)
        |> result.map(list.contains(_, b))
        |> result.unwrap(False),
      return: order.Lt,
    )

    order.Eq
  }
}
