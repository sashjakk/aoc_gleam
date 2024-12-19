import advent
import gleam/bool
import gleam/int
import gleam/list
import gleam/string
import rememo/memo

pub fn main() {
  let content = advent.read("./input/day_19.txt")

  let result_1 = advent.elapsed(fn() { part_1(content) })
  advent.print(day: 19, part: 1, result: result_1)

  let result_2 = advent.elapsed(fn() { part_2(content) })
  advent.print(day: 19, part: 2, result: result_2)
}

fn part_1(content: String) -> Int {
  let assert [patterns, towels] = string.split(content, "\n\n")
  let patterns = string.split(patterns, ", ")

  let towels =
    towels
    |> string.split("\n")
    |> list.filter(fn(it) { !string.is_empty(it) })

  use cache <- memo.create()
  towels
  |> list.map(arrangements(_, patterns, cache))
  |> list.count(fn(it) { it > 0 })
}

fn part_2(content: String) -> Int {
  let assert [patterns, towels] = string.split(content, "\n\n")
  let patterns = string.split(patterns, ", ")

  let towels =
    towels
    |> string.split("\n")
    |> list.filter(fn(it) { !string.is_empty(it) })

  use cache <- memo.create()
  towels
  |> list.map(arrangements(_, patterns, cache))
  |> int.sum
}

fn arrangements(towel: String, patterns: List(String), cache) -> Int {
  use <- memo.memoize(cache, towel)
  use <- bool.guard(string.is_empty(towel), 1)

  let matching = list.filter(patterns, string.starts_with(towel, _))
  use acc, pattern <- list.fold(matching, 0)
  acc
  + arrangements(
    string.drop_start(towel, string.length(pattern)),
    patterns,
    cache,
  )
}
