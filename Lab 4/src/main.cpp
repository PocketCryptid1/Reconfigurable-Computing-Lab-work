#include <cstring>
#include <fstream>

#include "lib.h"
#include <iostream>

using namespace std;

int main(int argc, char* argv[])
{
    if (argc == 4 && strcmp(argv[1], "-s") == 0) {
        std::ofstream stats(argv[2]);
        vector cooling_rates = {0.9999, 0.998, 0.9, 0.85, 0.8, 0.75, 0.7, 0.65, 0.6, 0.55, 0.5, 0.45, 0.4, 0.35, 0.3, 0.25, 0.2, 0.15, 0.1};

        for (double cooling_rate: cooling_rates) {
            circuit trial(cooling_rate);
            trial.read_file(argv[3]);
            trial.init_placement();
            int count = trial.anneal();
            double distance = trial.total_distance();
            stats << cooling_rate << '\t' << count << '\t' << distance << endl;
        }

        return 0;

    }

    if (argc == 3) {
        circuit c(0.998);
        c.read_file(argv[1]);
        c.init_placement();
        c.anneal();
        c.output(argv[2]);

        return 0;
    }

    cout << "Usage: " << endl
            << argv[0] << " <input_file> <output_file>" << endl
            << argv[0] << " -s <stats_file> <input_file>" << endl;
    return 1;
}