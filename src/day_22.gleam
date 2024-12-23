import gleam/pair
import gleam/dict
import advent
import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result

pub fn main() {
  let lines = advent.read_lines("./input/day_22.txt")

  let result_1 = advent.elapsed(fn() { part_1(lines) })
  advent.print(day: 22, part: 1, result: result_1)

  let result_2 = advent.elapsed(fn() { part_2(lines) })
  advent.print(day: 22, part: 2, result: result_2)
}

fn part_1(lines: List(String)) -> Int {
  lines
  |> list.filter_map(int.parse)
  |> list.map(calculate_secrets(_, 2000, 0, []))
  |> list.filter_map(list.first)
  |> int.sum
}

fn part_2(lines: List(String)) -> Int {
  lines
  |> list.filter_map(int.parse)
  |> list.flat_map(fn(number) {
    [number, ..calculate_secrets(number, 2000, 0, []) |> list.reverse]
    |> list.map(fn(it) { #(it, it % 10) })
    |> list.window(5)
    |> list.filter_map(fn(it) {
      let pattern = {
        use #(a, b) <- list.map(list.window_by_2(it))
        b.1 - a.1
      }

      use #(_, price) <- result.try(list.last(it))

      Ok(#(pattern, price))
    })
    // first value for pattern
    |> list.fold(dict.new(), fn(acc, it) {
      use ex <- dict.upsert(acc, it.0)
      case ex {
        Some(x) -> x
        None -> it.1
      }
    })
    |> dict.to_list
  })
  // sum for pattern
  |> list.fold(dict.new(), fn(acc, it) {
    use ex <- dict.upsert(acc, it.0)
    case ex {
      Some(x) -> x + it.1
      None -> it.1
    }
  })
  // most bananas collected with pattern
  |> dict.fold(#([], 0), fn(acc, k, v) {
    case v > acc.1 {
      True -> #(k, v)
      False -> acc
    }
  })
  |> pair.second
}

fn secret(number: Int) -> Int {
  let stage1 = int.bitwise_exclusive_or(number * 64, number) % 16_777_216
  let stage2 = int.bitwise_exclusive_or(stage1 / 32, stage1) % 16_777_216
  let stage3 = int.bitwise_exclusive_or(stage2 * 2048, stage2) % 16_777_216
  stage3
}

fn calculate_secrets(
  start: Int,
  times: Int,
  index: Int,
  acc: List(Int),
) -> List(Int) {
  use <- bool.guard(index >= times, acc)

  let next = secret(start)
  calculate_secrets(next, times, index + 1, [next, ..acc])
}
