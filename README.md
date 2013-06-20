# Command Runner [![Build Status](https://travis-ci.org/redjazz96/command-runner.png?branch=master)](https://travis-ci.org/redjazz96/command-runner)
Runs commands.

```Ruby
require 'command/runner'

line = Command::Runner.new("echo", "hello")
message = line.pass # => #<Command::Runner::Message:...>
message.exit_code   # => 0
message.stdout      # => "hello\n"
message.time        # => 0.00091773
message.process_id  # => 9622
message.line        # => "echo hello"
```

with interpolations...

```Ruby
line = Command::Runner.new("echo", "{interpolation}")
message = line.pass(:interpolation => "watermelons")
message.stdout # => "watermelons\n"
message.line   # => "echo watermelons"
```

that escapes bad stuff...

```Ruby
message = line.pass(:interpolation => "`uname -a`")
message.stdout # => "`uname -a`\n"
message.line   # => "echo \\`uname\\ -a\\`"
```

unless you don't want it to.

```Ruby
line = Command::Runner.new("echo", "{{interpolation}}")
message = line.pass(:interpolation => "`uname -a`")
message.stdout # => "Linux Hyperion 3.8.0-25-generic #37-Ubuntu SMP Thu Jun 6 20:47:07 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux\n"
message.line   # => "echo `uname -a`"
```

It can also use different methods to run commands...

```Ruby
line = Command::Runner.new("echo", "something")
line.backends = Command::Runner::Backends::Spawn.new
line.pass
```

but defaults to the best one.

## Compatibility
It works on

- MRI 2.0.0 and 1.9.3
- JRuby
- and REE

unless the travis build fails.
