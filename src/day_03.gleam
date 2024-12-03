import gleam/regexp
import advent
import gleam/int
import gleam/list
import gleam/option
import gleam/result

pub fn main() {
  let content = advent.read("./input/day_03.txt")

  let result_1 = advent.elapsed(fn() { part_1(content) })
  advent.print(day: 3, part: 1, result: result_1)

  let result_2 = advent.elapsed(fn() { part_2(content) })
  advent.print(day: 3, part: 2, result: result_2)
}

fn part_1(content: String) -> Int {
  let assert Ok(re) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")

  regexp.scan(re, content)
  |> list.map(fn(it) { it.submatches })
  |> list.map(fn(numbers) {
    numbers
    |> list.filter_map(option.to_result(_, Nil))
    |> list.filter_map(int.parse)
    |> list.reduce(int.multiply)
    |> result.unwrap(0)
  })
  |> int.sum
}

fn part_2(content: String) -> Int {
  let assert Ok(re) =
    regexp.from_string("mul\\((\\d+),(\\d+)\\)|don\\'t\\(\\)|do\\(\\)")

  regexp.scan(re, content)
  |> enabled_instructions(True, list.new())
  |> list.map(fn(it) { it.submatches })
  |> list.map(fn(numbers) {
    numbers
    |> list.filter_map(option.to_result(_, Nil))
    |> list.filter_map(int.parse)
    |> list.reduce(int.multiply)
    |> result.unwrap(0)
  })
  |> int.sum
}

fn enabled_instructions(
  instructions: List(regexp.Match),
  toggle: Bool,
  acc: List(regexp.Match),
) {
  case toggle, instructions {
    _, [] -> acc
    t, [a, ..rest] -> {
      case a.content {
        "don't" <> _left -> enabled_instructions(rest, False, acc)
        "do(" <> _left -> enabled_instructions(rest, True, acc)
        "mul" <> _left -> {
          case t {
            True -> enabled_instructions(rest, t, [a, ..acc])
            False -> enabled_instructions(rest, t, acc)
          }
        }
        _ -> enabled_instructions(rest, t, acc)
      }
    }
  }
}
