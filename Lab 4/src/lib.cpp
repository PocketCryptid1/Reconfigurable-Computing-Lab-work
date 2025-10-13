#include <fstream>
#include <sstream>
#include <iostream>
#include "lib.h"

circuit::circuit(){
    grid_x = 0;
    grid_y = 0;
    num_nodes = 0;
    edges = nullptr;
}

void circuit::read_file(char *filename) {
    std::ifstream infile(filename);
    if (!infile) {
        std::cerr << "Error opening file: " << filename << std::endl;
        return;
    }

    std::string line;
    int edge_count = 0;

    while (std::getline(infile, line)) {
        std::istringstream iss(line);
        char type;
        iss >> type;

        if (type == 'g') {
            iss >> grid_x >> grid_y;
        } else if (type == 'v') {
            iss >> num_nodes;
            edges = new std::pair<int, int>[num_nodes * num_nodes]; // Over-allocate, will resize later
        } else if (type == 'e') {
            int n1, n2;
            iss >> n1 >> n2;
            edges[edge_count++] = std::make_pair(n1, n2);
        }
    }
    
    infile.close();
}