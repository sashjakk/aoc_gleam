import advent
import coordinate
import gleam/bool
import gleam/dict.{type Dict}
import gleam/function
import gleam/list
import gleam/result
import gleam/string
import table

pub fn main() {
  let content = advent.read("./input/day_12.txt")

  let result_1 = advent.elapsed(fn() { part_1(content) })
  advent.print(day: 12, part: 1, result: result_1)

  let result_2 = advent.elapsed(fn() { part_2(content) })
  advent.print(day: 12, part: 2, result: result_2)
}

fn part_1(content: String) -> Int {
  let grid =
    content
    |> string.to_graphemes
    |> table.from

  let regions =
    to_regions(grid, [])
    |> list.map(dict.values)

  use acc, region <- list.fold(regions, 0)
  let per_region = {
    use acc, cell <- list.fold(region, 0)
    acc + cell.borders * list.length(region)
  }
  acc + per_region
}

fn part_2(content: String) -> Int {
  let grid =
    content
    |> string.to_graphemes
    |> table.from

  let regions =
    to_regions(grid, [])
    |> list.map(dict.values)

  use acc, region <- list.fold(regions, 0)
  let per_region = {
    use acc, cell <- list.fold(region, 0)
    acc + cell.angles * list.length(region)
  }
  acc + per_region
}

type Cell {
  Cell(position: #(Int, Int), borders: Int, angles: Int)
}

fn borders(grid: Dict(#(Int, Int), String), point: #(Int, Int)) -> Int {
  use acc, neighbour <- list.fold(point |> coordinate.neighbours_4, 4)
  case dict.get(grid, point), dict.get(grid, neighbour) {
    Ok(x), Ok(y) ->
      case x == y {
        True -> acc - 1
        False -> acc
      }
    _, _ -> acc
  }
}

fn angles(grid: Dict(#(Int, Int), String), point: #(Int, Int)) -> Int {
  case dict.get(grid, point) {
    Error(_) -> 0
    Ok(current) -> {
      let neighbours =
        [
          #(-1, 0),
          #(1, 0),
          #(0, -1),
          #(0, 1),
          #(-1, -1),
          #(-1, 1),
          #(1, -1),
          #(1, 1),
        ]
        |> list.map(coordinate.add(point, _))
        |> list.map(fn(neighbour) {
          neighbour
          |> dict.get(grid, _)
          |> result.map(fn(it) { it == current })
          |> result.unwrap(False)
        })

      case neighbours {
        [up, down, left, right, up_left, up_right, down_left, down_right] -> {
          [
            // outer
            { !up && !left },
            { !up && !right },
            { !down && !left },
            { !down && !right },
            // inner
            { up && left && !up_left },
            { up && right && !up_right },
            { down && left && !down_left },
            { down && right && !down_right },
          ]
          |> list.count(function.identity)
        }
        _ -> 0
      }
    }
  }
}

fn floodfill(
  grid: Dict(#(Int, Int), String),
  current: #(Int, Int),
  points: Dict(#(Int, Int), Cell),
) -> Dict(#(Int, Int), Cell) {
  let neighbours = {
    let all = coordinate.neighbours_4(current)
    use neighbour <- list.filter_map(all)

    use original <- result.try(dict.get(grid, current))
    use value <- result.try(dict.get(grid, neighbour))
    use <- bool.guard(
      when: value != original || dict.has_key(points, neighbour),
      return: Error(Nil),
    )

    Ok(neighbour)
  }

  case neighbours {
    [] ->
      Cell(
        position: current,
        borders: borders(grid, current),
        angles: angles(grid, current),
      )
      |> dict.insert(points, current, _)

    next -> {
      let updated =
        next
        |> list.map(fn(it) {
          #(
            it,
            Cell(
              position: it,
              borders: borders(grid, it),
              angles: angles(grid, it),
            ),
          )
        })
        |> dict.from_list
        |> dict.merge(points)

      use acc, n <- list.fold(next, updated)
      floodfill(grid, n, acc)
    }
  }
}

fn to_regions(
  grid: Dict(#(Int, Int), String),
  acc: List(Dict(#(Int, Int), Cell)),
) {
  case dict.keys(grid) {
    [] -> acc
    [it, ..] -> {
      let region = floodfill(grid, it, dict.new())

      let left = {
        use key, _ <- dict.filter(grid)
        !dict.has_key(region, key)
      }

      to_regions(left, [region, ..acc])
    }
  }
}
