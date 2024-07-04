# Mdiv pre-prepared tests

## Usages

Copy your mdiv.asm to directory with files. Then launch tests with
>bash ./run.sh>

## Mediator

The mediator passes inputs to mdiv and then prints the results. It catches any overflow that may be thrown.

### Input:

```
<number of lines>
<n> <x[0]> <x[1]> ... <x[n-1]> <divider>
```