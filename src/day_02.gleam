import advent
import gleam/bool
import gleam/int
import gleam/list
import gleam/string

pub fn main() {
  let lines = advent.read_lines("./input/day_02.txt")

  let result_1 = advent.elapsed(fn() { part_1(lines) })
  advent.print(day: 2, part: 1, result: result_1)

  let result_2 = advent.elapsed(fn() { part_2(lines) })
  advent.print(day: 2, part: 2, result: result_2)
}

fn part_1(lines: List(String)) -> Int {
  lines
  |> list.map(fn(line) {
    line
    |> string.split(" ")
    |> list.filter_map(int.parse)
  })
  |> list.filter(is_safe)
  |> list.length
}

fn part_2(lines: List(String)) -> Int {
  lines
  |> list.map(fn(line) {
    line
    |> string.split(" ")
    |> list.filter_map(int.parse)
  })
  |> list.filter(fn(it) {
    it
    |> explode
    |> list.any(is_safe)
  })
  |> list.length
}

fn check(numbers: List(Int), predicate: fn(Int, Int) -> Bool) -> Bool {
  case numbers {
    [a, b] -> predicate(a, b)
    [a, b, ..rest] ->
      case predicate(a, b) {
        True -> check([b, ..rest], predicate)
        False -> False
      }
    _ -> False
  }
}

fn is_safe(numbers: List(Int)) -> Bool {
  use <- bool.guard(
    when: {
      use a, b <- check(numbers)
      let delta = b - a
      delta >= 1 && delta <= 3
    },
    return: True,
  )

  use <- bool.guard(
    when: {
      use a, b <- check(numbers)
      let delta = b - a
      delta >= -3 && delta <= -1
    },
    return: True,
  )

  False
}

fn explode(numbers: List(Int)) -> List(List(Int)) {
  do_explode(numbers, 0, list.new())
}

fn do_explode(
  numbers: List(Int),
  index: Int,
  acc: List(List(Int)),
) -> List(List(Int)) {
  case index, list.length(numbers) {
    i, length if i < length -> {
      let next =
        list.append(list.take(numbers, index), list.drop(numbers, index + 1))

      do_explode(numbers, i + 1, [next, ..acc])
    }
    _, _ -> acc
  }
}
