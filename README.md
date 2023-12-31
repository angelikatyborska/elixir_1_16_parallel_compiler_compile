# Output of `Kernel.ParallelCompiler.compile/2` unexpectedly different between Elixir 1.15.7 and 1.16.0

## TL;DR

When run **from an escript**, `Kernel.ParallelCompiler.compile/2` in Elixir 1.15.7 reports both compile warnings and runtime warnings, but in Elixir 1.16.0 it only reports compile warnings.

## Reproduction steps

```
cd elixir_1_15
asdf install
mix escript.build
./elixir_1_15 ../example.ex
```

Output:

```elixir
[lib/elixir115.ex:25: Elixir115.main/1]
compile_warnings #=> [
  %{
    message: "Behaviour.defcallback/1 is deprecated. Use the @callback module attribute instead",
    position: 4,
    file: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
    stacktrace: [
      {Example, :__MODULE__, 0,
       [
         file: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
         line: 4
       ]}
    ],
    severity: :warning
  }
]

[lib/elixir115.ex:26: Elixir115.main/1]
runtime_warnings #=> [
  %{
    message: "HashDict.new/0 is deprecated. Use maps and the Map module instead",
    position: 7,
    file: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
    stacktrace: [
      {Example, :some_function, 0,
       [
         file: ~c"/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
         line: 7
       ]}
    ],
    severity: :warning
  },
  %{
    message: "HashSet.member?/2 is deprecated. Use the MapSet module instead",
    position: 8,
    file: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
    stacktrace: [
      {Example, :some_function, 0,
       [
         file: ~c"/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
         line: 8
       ]}
    ],
    severity: :warning
  },
  %{
    message: "HashSet.new/0 is deprecated. Use the MapSet module instead",
    position: 8,
    file: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
    stacktrace: [
      {Example, :some_function, 0,
       [
         file: ~c"/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
         line: 8
       ]}
    ],
    severity: :warning
  }
]
```

Repeating the same steps replacing `elixir_1_15` with `elixir_1_16`, we get the output:

```elixir
[lib/elixir116.ex:25: Elixir116.main/1]
compile_warnings #=> [
  %{
    message: "Behaviour.defcallback/1 is deprecated. Use the @callback module attribute instead",
    position: {4, 13},
    file: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
    stacktrace: [
      {Example, :__MODULE__, 0,
       [
         file: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
         column: 13,
         line: 4
       ]}
    ],
    source: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
    span: nil,
    severity: :warning
  }
]

[lib/elixir116.ex:26: Elixir116.main/1]
runtime_warnings #=> []
```

### Conclusion

In Elixir 1.15.7, `Kernel.ParallelCompiler.compile/2` ran from an escript reports some runtime warnings. In Elixir 1.16.0, reported runtime warnings are empty when compiling the same file.

## escript vs iex

The difference in outputs appears when running `Kernel.ParallelCompiler.compile/2` from an escript, but it doesn't appear from running it from iex. Compare:

```
cd elixir_1_15
iex -S mix
```

```elixir
iex(1)> Elixir115.main(["../example.ex"])
warning: Behaviour.defcallback/1 is deprecated. Use the @callback module attribute instead
  /Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex:4: Example (module)

warning: HashDict.new/0 is deprecated. Use maps and the Map module instead
  /Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex:7: Example.some_function/0

warning: HashSet.member?/2 is deprecated. Use the MapSet module instead
  /Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex:8: Example.some_function/0

warning: HashSet.new/0 is deprecated. Use the MapSet module instead
  /Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex:8: Example.some_function/0

[lib/elixir115.ex:25: Elixir115.main/1]
compile_warnings #=> [
  %{
    message: "Behaviour.defcallback/1 is deprecated. Use the @callback module attribute instead",
    position: 4,
    file: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
    stacktrace: [
      {Example, :__MODULE__, 0,
       [
         file: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
         line: 4
       ]}
    ],
    severity: :warning
  }
]

[lib/elixir115.ex:26: Elixir115.main/1]
runtime_warnings #=> [
  %{
    message: "HashDict.new/0 is deprecated. Use maps and the Map module instead",
    position: 7,
    file: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
    stacktrace: [
      {Example, :some_function, 0,
       [
         file: ~c"/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
         line: 7
       ]}
    ],
    severity: :warning
  },
  %{
    message: "HashSet.member?/2 is deprecated. Use the MapSet module instead",
    position: 8,
    file: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
    stacktrace: [
      {Example, :some_function, 0,
       [
         file: ~c"/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
         line: 8
       ]}
    ],
    severity: :warning
  },
  %{
    message: "HashSet.new/0 is deprecated. Use the MapSet module instead",
    position: 8,
    file: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
    stacktrace: [
      {Example, :some_function, 0,
       [
         file: ~c"/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
         line: 8
       ]}
    ],
    severity: :warning
  }
]

:ok
```

and then the same for `elixir_1_16`:

```elixir
iex(1)> Elixir116.main(["../example.ex"])
    warning: Behaviour.defcallback/1 is deprecated. Use the @callback module attribute instead
    │
  4 │   Behaviour.defcallback(init)
    │             ~
    │
    └─ /Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex:4:13: Example (module)

    warning: HashDict.new/0 is deprecated. Use maps and the Map module instead
    │
  7 │     HashDict.new()
    │              ~
    │
    └─ /Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex:7:14: Example.some_function/0

    warning: HashSet.member?/2 is deprecated. Use the MapSet module instead
    │
  8 │     HashSet.member?(HashSet.new(), :foo)
    │             ~
    │
    └─ /Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex:8:13: Example.some_function/0

    warning: HashSet.new/0 is deprecated. Use the MapSet module instead
    │
  8 │     HashSet.member?(HashSet.new(), :foo)
    │                             ~
    │
    └─ /Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex:8:29: Example.some_function/0

[lib/elixir116.ex:25: Elixir116.main/1]
compile_warnings #=> [
  %{
    message: "Behaviour.defcallback/1 is deprecated. Use the @callback module attribute instead",
    position: {4, 13},
    file: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
    stacktrace: [
      {Example, :__MODULE__, 0,
       [
         file: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
         column: 13,
         line: 4
       ]}
    ],
    source: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
    span: nil,
    severity: :warning
  }
]

[lib/elixir116.ex:26: Elixir116.main/1]
runtime_warnings #=> [
  %{
    message: "HashDict.new/0 is deprecated. Use maps and the Map module instead",
    position: {7, 14},
    file: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
    stacktrace: [
      {Example, :some_function, 0,
       [
         file: ~c"/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
         line: 7,
         column: 14
       ]}
    ],
    source: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
    span: nil,
    severity: :warning
  },
  %{
    message: "HashSet.member?/2 is deprecated. Use the MapSet module instead",
    position: {8, 13},
    file: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
    stacktrace: [
      {Example, :some_function, 0,
       [
         file: ~c"/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
         line: 8,
         column: 13
       ]}
    ],
    source: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
    span: nil,
    severity: :warning
  },
  %{
    message: "HashSet.new/0 is deprecated. Use the MapSet module instead",
    position: {8, 29},
    file: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
    stacktrace: [
      {Example, :some_function, 0,
       [
         file: ~c"/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
         line: 8,
         column: 29
       ]}
    ],
    source: "/Users/angelika/Documents/code/exercism/parallel_compiler_compile/example.ex",
    span: nil,
    severity: :warning
  }
]

:ok
```

### Conclusion

Both in Elixir 1.15.7 and 1.16.0 the same warnings are reported when running `Kernel.ParallelCompiler.compile/2` from `iex`. In Elixir 1.16.0, runtime warnings are not reported only when running from an escript.

I don't understand why - there must be some differentiating factor.
