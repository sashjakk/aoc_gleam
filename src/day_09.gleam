import advent
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn main() {
  let content = advent.read("./input/day_09.txt")

  let result_1 = advent.elapsed(fn() { part_1(content) })
  advent.print(day: 9, part: 1, result: result_1)

  let result_2 = advent.elapsed(fn() { part_2(content) })
  advent.print(day: 9, part: 2, result: result_2)
}

fn part_1(content: String) -> Int {
  let blocks =
    content
    |> string.to_graphemes
    |> decode(0, [])

  compress(blocks, [])
  |> checksum
}

fn part_2(content: String) -> Int {
  let blocks =
    content
    |> string.to_graphemes
    |> blocks
    |> rearrange

  blocks
  |> list.flat_map(fn(it) { list.repeat(it.id, it.size) })
  |> checksum
}

fn decode(disk_map: List(String), index: Int, acc: List(String)) {
  case disk_map {
    [a, b, ..rest] ->
      decode(
        rest,
        index + 1,
        list.flatten([
          acc,
          list.repeat(int.to_string(index), int.parse(a) |> result.unwrap(0)),
          list.repeat(".", int.parse(b) |> result.unwrap(0)),
        ]),
      )
    _ -> acc
  }
}

fn compress(content: List(String), acc: List(String)) {
  case content {
    [] -> acc
    [a, ..rest] -> {
      case a {
        "." ->
          compress(
            rest
              |> list.reverse
              |> list.drop_while(fn(it) { it == "." })
              |> list.drop(1)
              |> list.reverse,
            list.flatten([
              acc,
              rest
                |> list.reverse
                |> list.drop_while(fn(it) { it == "." })
                |> list.take(1),
            ]),
          )
        _ -> compress(rest, list.flatten([acc, [a]]))
      }
    }
  }
}

type Block {
  Block(id: String, size: Int)
}

fn blocks(disk_map: List(String)) {
  do_blocks(disk_map, 0, [])
}

fn do_blocks(disk_map: List(String), index: Int, acc: List(Block)) {
  case disk_map {
    [a, b, ..rest] ->
      do_blocks(rest, index + 1, [
        Block(".", int.parse(b) |> result.unwrap(0)),
        Block(int.to_string(index), int.parse(a) |> result.unwrap(0)),
        ..acc
      ])
    _ ->
      acc
      |> list.reverse
      |> list.filter(fn(it) { it.size > 0 })
  }
}

fn rearrange(filesystem: List(Block)) {
  do_rearrange_blocks(filesystem, [])
}

fn do_rearrange_blocks(filesystem: List(Block), acc: List(Block)) {
  case filesystem {
    [] -> acc
    [block, ..rest] ->
      case block {
        Block(id, size) if id == "." -> {
          let #(left, right) =
            rest
            |> list.reverse
            |> list.split_while(fn(it) { it.id == "." || it.size > size })

          let last = right |> list.first

          case last {
            Ok(it) -> {
              let leftover = case { size - it.size > 0 } {
                True -> [Block(".", size - it.size)]
                False -> []
              }

              let pre = right |> list.drop(1) |> list.reverse
              let post = left |> list.reverse

              let placeholder = [Block(".", it.size)]

              do_rearrange_blocks(
                list.flatten([leftover, pre, placeholder, post]),
                list.flatten([acc, [it]]),
              )
            }

            _ -> do_rearrange_blocks(rest, list.flatten([acc, [block]]))
          }
        }
        other -> do_rearrange_blocks(rest, list.flatten([acc, [other]]))
      }
  }
}

fn checksum(file_ids: List(String)) {
  use acc, it, index <- list.index_fold(file_ids, 0)
  case it {
    "." -> acc
    digit -> acc + { int.parse(digit) |> result.unwrap(0) } * index
  }
}

fn to_string(block: Block) {
  string.repeat(block.id, block.size)
}
