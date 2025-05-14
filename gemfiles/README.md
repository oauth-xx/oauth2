# History

`faraday` v0.17.3 is the first version that stops using `&Proc.new` for block forwarding,
   and thus is the oldest version oauth2 is compatible with.

```ruby
gem "faraday", [">= 0.17.3", "< 3.0"]
```

# Ruby

We use the Github Action `ruby/setup-ruby@master` to install Ruby, and it has a matrix of
[supported versions](https://github.com/ruby/setup-ruby/blob/master/README.md#supported-versions) (copied below).

| Interpreter           | Versions                                                                                 |
|-----------------------|------------------------------------------------------------------------------------------|
| `ruby`                | 1.9.3, 2.0.0, 2.1.9, 2.2, all versions from 2.3.0 until 3.1.1, head, debug, mingw, mswin |
| `jruby`               | 9.1.17.0 - 9.3.3.0, head                                                                 |
| `truffleruby`         | 19.3.0 - 22.0.0, head                                                                    |
| `truffleruby+graalvm` | 21.2.0 - 22.0.0, head                                                                    |

In the naming of gemfiles, we will use the below shorthand for interpreter,
and version. Platforms will be represented without modification.

| Interpreter           | Shorthand |
|-----------------------|-----------|
| `ruby`                | r         |
| `jruby`               | jr        |
| `truffleruby`         | tr        |
| `truffleruby+graalvm` | trg       |

Building onto that, we can add the MRI target spec,
since that's what all Rubygems use for minimum version compatibility.

| Interpreter + Version      | MRI spec | Shorthand  |
|----------------------------|----------|------------|
| ruby-1.9.3                 | 1.9      | r1_9       |
| ruby-2.0.0                 | 2.0      | r2_0       |
| ruby-2.1.9                 | 2.1      | r2_1       |
| ruby-2.2.x                 | 2.2      | r2_2       |
| ruby-2.3.x                 | 2.3      | r2_3       |
| ruby-2.4.x                 | 2.4      | r2_4       |
| ruby-2.5.x                 | 2.5      | r2_5       |
| ruby-2.6.x                 | 2.6      | r2_6       |
| ruby-2.7.x                 | 2.7      | r2_7       |
| ruby-3.0.x                 | 3.0      | r3_0       |
| ruby-3.1.x                 | 3.1      | r3_1       |
| ruby-head                  | 3.2      | rH3_2      |
| ruby-mingw                 | (?)      | rmin       |
| ruby-mswin                 | (?)      | rMS        |
| jruby-9.1.x.x              | 2.3      | jr9_1-r2_3 |
| jruby-9.2.x.x              | 2.5      | jr9_2-r2_5 |
| jruby-9.3.x.x              | 2.6      | jr9_3-r2_6 |
| jruby-head                 | 2.7      | jrH-r2_7   |
| truffleruby-19.3.x         | 2.5(?)   | tr19-r2_5  |
| truffleruby-20.x.x         | 2.6.5    | tr20-r2_6  |
| truffleruby-21.x.x         | 2.7.4    | tr21-r2_7  |
| truffleruby-22.x.x         | 3.0.2    | tr22-r3_0  |
| truffleruby-head           | 3.1(?)   | trH-r3_1   |
| truffleruby+graalvm-21.2.x | 2.7.4    | trg21-r2_7 |
| truffleruby+graalvm-22.x.x | 3.0.2    | trg22-r3_0 |
| truffleruby+graalvm-head   | 3.1(?)   | trgH-r3_1  |

We will run tests on as many of these as possible, in a matrix with each supported major version of `faraday`,
which means 0.17.3+ (as `f0`), 1.10.x (as `f1`), 2.2.x (as `f2`).

Discrete versions of `faraday` to test against, as of 2025.05.14, with minimum version of Ruby for each:

* 2.9.0, Ruby >= 3.0
* 2.2.0, Ruby >= 2.6
* 1.10.0, Ruby >= 2.4
* 0.17.4, Ruby >= 1.9

❌ - Incompatible
✅ - Official Support
🚧 - Unofficial Support
🤡 - Incidental Compatibility
🙈 - Unknown Compatibility

| Shorthand  | f0 - 0.17.3+     | f1 - 1.10.x      | f2 - 2.2.x      |
|------------|------------------|------------------|-----------------|
| r1_9       | 🤡 f0-r1_9       | ❌                | ❌               |
| r2_0       | 🤡 f0-r2_0       | ❌                | ❌               |
| r2_1       | 🤡 f0-r2_1       | ❌                | ❌               |
| r2_2       | 🤡 f0-r2_2       | ❌                | ❌               |
| r2_3       | 🚧 f0-r2_3       | ❌                | ❌               |
| r2_4       | 🚧 f0-r2_4       | 🚧 f1-r2_4       | ❌               |
| r2_5       | 🚧 f0-r2_5       | 🚧 f1-r2_5       | ❌               |
| r2_6       | 🚧 f0-r2_6       | 🚧 f1-r2_6       | 🚧 f2-r2_6      |
| r2_7       | ✅ f0-r2_7        | ✅ f1-r2_7        | ✅ f2-r2_7       |
| r3_0       | ✅ f0-r3_0        | ✅ f1-r3_0        | ✅ f2-r3_0       |
| r3_1       | ✅ f0-r3_1        | ✅ f1-r3_1        | ✅ f2-r3_1       |
| rH3_2      | 🚧 f0-rH3_2      | 🚧 f1-rH3_2      | 🚧 f2-rH3_2     |
| rmin       | 🙈 f0-rmin       | 🙈 f1-rmin       | 🙈 f2-rmin      |
| rMS        | 🙈 f0-rMS        | 🙈 f1-rMS        | 🙈 f2-rMS       |
| jr9_1-r2_3 | 🚧 f0-jr9_1-r2_3 | ❌                | ❌               |
| jr9_2-r2_5 | 🚧 f0-jr9_2-r2_5 | 🚧 f1-jr9_2-r2_5 | ❌               |
| jr9_3-r2_6 | ✅ f0-jr9_3-r2_6  | ✅ f1-jr9_3-r2_6  | ✅ f2-jr9_3-r2_6 |
| jrH-r2_7   | 🚧 f0-jrH-r2_7    | 🚧 f1-jrH-r2_7    | 🚧 f2-jrH-r2_7   |
| tr19-r2_5  | 🚧 f0-tr19-r2_5  | 🚧 f1-tr19-r2_5  | ❌               |
| tr20-r2_6  | 🚧 f0-tr20-r2_6  | 🚧 f1-tr20-r2_6  | 🚧 f2-tr20-r2_6 |
| tr21-r2_7  | ✅ f0-tr21-r2_7   | ✅ f1-tr21-r2_7   | ✅ f2-tr21-r2_7  |
| tr22-r3_0  | ✅ f0-tr22-r3_0   | ✅ f1-tr22-r3_0   | ✅ f2-tr22-r3_0  |
| trH-r3_1   | 🚧 f0-trH-r3_1   | 🚧 f1-trH-r3_1   | 🚧 f2-trH-r3_1  |
| trg21-r2_7 | ✅ f0-trg21-r2_7  | ✅ f1-trg21-r2_7  | ✅ f2-trg21-r2_7 |
| trg22-r3_0 | ✅ f0-trg22-r3_0  | ✅ f1-trg22-r3_0  | ✅ f2-trg22-r3_0 |
| trgH-r3_1  | 🚧 f0-trgH-r3_1  | 🚧 f1-trgH-r3_1  | 🚧 f2-trgH-r3_1 |
