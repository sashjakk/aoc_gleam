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

  manuals
  |> list.filter(valid(_, rules))
  |> list.filter_map(fn(line) {
    line
    |> list.split(list.length(line) / 2)
    |> pair.second
    |> list.first
  })
  |> int.sum
}

fn part_2(content: List(String)) -> Int {
  let #(rules, manuals) = parse(content)

  let sort_with = fn(rules: Dict(Int, Rule)) {
    fn(a: Int, b: Int) {
      case dict.get(rules, b) {
        Error(_) -> order.Eq
        Ok(Rule(before, _)) -> {
          case list.contains(before, a) {
            True -> order.Lt
            False -> order.Gt
          }
        }
      }
    }
  }

  manuals
  |> list.filter(fn(it) { valid(it, rules) |> bool.negate })
  |> list.map(list.sort(_, sort_with(rules)))
  |> list.filter_map(fn(line) {
    line
    |> list.split(list.length(line) / 2)
    |> pair.second
    |> list.first
  })
  |> int.sum
}

type Rule {
  Rule(before: List(Int), after: List(Int))
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
      [a, b] -> {
        acc
        |> dict.upsert(a, fn(existing) {
          case existing {
            Some(rule) -> Rule(..rule, after: [b, ..rule.after])
            None -> Rule(before: [], after: [b])
          }
        })
        |> dict.upsert(b, fn(existing) {
          case existing {
            Some(rule) -> Rule(..rule, before: [a, ..rule.before])
            None -> Rule(before: [a], after: [])
          }
        })
      }
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

fn valid(line: List(Int), rules: Dict(Int, Rule)) -> Bool {
  let range = list.range(1, list.length(line) - 1)
  use index <- list.all(range)

  let #(raw, right) = list.split(line, index)
  let left = list.take(raw, index - 1)

  {
    use key <- result.try(
      raw
      |> list.last
      |> result.map_error(fn(_) { False }),
    )

    use Rule(before, after) <- result.try(
      rules
      |> dict.get(key)
      |> result.map_error(fn(_) { False }),
    )

    {
      list.all(left, list.contains(before, _))
      && list.all(right, list.contains(after, _))
    }
    |> Ok
  }
  |> result.unwrap(False)
}
