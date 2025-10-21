# Simulated Annealing

## Instructions

Use `make` to build. Make will create a `place.exe` executable. If you execute the following command, make will execute `./place.exe input.txt output.txt`:
```shell
make run
```

However, If you wish to specify the input and output files, you must execute the created `place.exe` with the following usage:
```shell
./place.exe <input-file> <output-file>
```

These commands should be executed from the same directory as this README. 

Finally, the program offers a stats execution. This iterations through a set list
of cooling rates and compares the efficiency and accuracy of each. To execute this, run
```shell
./place.exe -s <stats-file> <input-file>
```
There is also a make execution, with the `<input-file>` set to a default `input.txt`. It can be run via
```shell
make stats
```