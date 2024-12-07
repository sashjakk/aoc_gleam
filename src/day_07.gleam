import advent
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn main() {
  let content = advent.read_lines("./input/day_07.txt")

  let result_1 = advent.elapsed(fn() { part_1(content) })
  advent.print(day: 7, part: 1, result: result_1)

  let result_2 = advent.elapsed(fn() { part_2(content) })
  advent.print(day: 7, part: 2, result: result_2)
}

fn part_1(content: List(String)) -> Int {
  solve(content, [int.add, int.multiply])
}

fn part_2(content: List(String)) -> Int {
  solve(content, [int.add, int.multiply, concat])
}

fn parse(equation: String) -> #(Int, List(Int)) {
  {
    use #(left, right) <- result.try(
      string.split_once(equation, ":")
      |> result.map_error(fn(_) { #(0, []) }),
    )

    use result <- result.try(
      int.parse(left)
      |> result.map_error(fn(_) { #(0, []) }),
    )

    let numbers =
      right
      |> string.split(" ")
      |> list.filter_map(int.parse)

    Ok(#(result, numbers))
  }
  |> result.unwrap_both
}

fn evaluate(
  expected: Int,
  numbers: List(Int),
  operators: List(fn(Int, Int) -> Int),
  initial: List(Int),
) {
  use acc, number <- list.fold(numbers, initial)
  use it <- list.flat_map(acc)

  operators
  |> list.map(fn(apply) { apply(it, number) })
  |> list.filter(fn(it) { it <= expected })
}

fn solve(content: List(String), operations: List(fn(Int, Int) -> Int)) {
  let equations = list.map(content, parse)
  use acc, equation <- list.fold(equations, 0)

  let #(expected, numbers) = equation
  let #(initial, rest) = numbers |> list.split(1)

  let results = evaluate(expected, rest, operations, initial)
  case list.contains(results, expected) {
    True -> acc + expected
    False -> acc
  }
}

fn concat(a: Int, b: Int) -> Int {
  { int.to_string(a) <> int.to_string(b) }
  |> int.parse
  |> result.unwrap(0)
}
