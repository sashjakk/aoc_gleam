import birl
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import humanise/time
import simplifile

pub fn print(day day: Int, part part: Int, result result: #(Int, Int)) {
  let day = day |> int.to_string |> string.pad_start(2, "0")
  let part = part |> int.to_string
  let value = result.1 |> int.to_string
  let elapsed =
    result.0
    |> int.to_float
    |> time.Microseconds
    |> time.humanise
    |> time.to_string

  {
    "Day " <> day <> " / " <> part <> " - " <> value <> " (" <> elapsed <> ")\n"
  }
  |> io.print
}

pub fn elapsed(body: fn() -> a) -> #(Int, a) {
  let start = birl.monotonic_now()
  let result = body()
  let end = birl.monotonic_now()
  #(end - start, result)
}

pub fn read_lines(path: String) -> List(String) {
  path
  |> simplifile.read
  |> result.map(fn(content) {
    content
    |> string.split("\n")
    |> list.filter(fn(it) { !string.is_empty(it) })
  })
  |> result.unwrap([])
}
