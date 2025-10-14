#include "lib.h"
#include <iostream>

using namespace std;

int main(int argc, char* argv[])
{
    if (argc < 3) {
        cout << "Usage: " << argv[0] << " <input_file> <output_file>\n";
        return 1;
    }

    circuit c;
    c.read_file(argv[1]);
    c.init_placement();
    c.anneal();
    c.output(argv[2]);

    return 0;
}