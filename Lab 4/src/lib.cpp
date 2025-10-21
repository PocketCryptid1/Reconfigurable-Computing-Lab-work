#include <fstream>
#include <sstream>
#include <iostream>
#include <random>
#include <set>

#include "lib.h"

circuit::circuit(double cooling_rate) : cooling_rate(cooling_rate) {
    grid_x = 0;
    grid_y = 0;
    num_nodes = 0;
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
        } else if (type == 'e') {
            int n1, n2;
            iss >> n1 >> n2;
            edges.push_back(make_pair(n1, n2));
        }
    }
    
    infile.close();
    return;
}

void circuit::init_placement(){
    random_device rd;
    mt19937 gen(rd());
    uniform_int_distribution<> dis_x(0, grid_x - 1);
    uniform_int_distribution<> dis_y(0, grid_y - 1);

    placements.clear();
    set<pair<int, int>> used;

    for (int i = 0; i < num_nodes; ++i) {
        int x, y;
        do {
            x = dis_x(gen);
            y = dis_y(gen);
        } while (used.count(make_pair(x, y)) > 0);

        placements.push_back(make_pair(x, y));
        used.insert(make_pair(x, y));
    }
}

double circuit::score(){
    double total_score = 0;
    for (const auto& edge : edges) {
        int n1 = edge.first;
        int n2 = edge.second;

        if (n1 < 0 || n1 >= placements.size() || n2 < 0 || n2 >= placements.size()) {
            std::cerr << "Error: Node index out of bounds." << std::endl;
            continue;
        }

        total_score += distance(n1, n2);
    }
    return total_score; 
}

bool circuit::is_used(int x, int y){
    for(const auto& p : placements){
        if(p.first == x && p.second == y){
            return true;
        }
    }
    return false;
}

double circuit::distance(int n1, int n2){
    if (n1 < 0 || n1 >= placements.size() || n2 < 0 || n2 >= placements.size()) {
        std::cerr << "Error: Node index out of bounds." << std::endl;
        return -1; // Indicate an error
    }

    int x1 = placements[n1].first;
    int y1 = placements[n1].second;
    int x2 = placements[n2].first;
    int y2 = placements[n2].second;

    return sqrt(abs(x1 - x2)*abs(x1 - x2) + abs(y1 - y2)*abs(y1 - y2));
}

int circuit::anneal(){
    //initial parameters
    double heat = 50000;
    double current_score = score();
    int count = 0;

    //initialize random generators
    random_device rd;
    mt19937 gen(rd());
    uniform_int_distribution<> dis_x(0, grid_x - 1);
    uniform_int_distribution<> dis_y(0, grid_y - 1);
    uniform_int_distribution<> dis_node(0, num_nodes - 1);
    uniform_real_distribution<> dis_prob(0.0, 1.0);

    while(heat > 1){
        //select a random node to move
        count++;
        int node = dis_node(gen);
        int old_x = placements[node].first;
        int old_y = placements[node].second;

        //propose a new position
        int new_x, new_y;
        do {
            new_x = dis_x(gen);
            new_y = dis_y(gen);
        } while (is_used(new_x, new_y));

        //move the node
        placements[node] = make_pair(new_x, new_y);
        double new_score = score();
        double score_diff = new_score - current_score;

        //decide whether to accept the move
        if(score_diff < 0){
            current_score = new_score;
        } else {
            double acceptance_prob = exp(-score_diff / heat);
            if(dis_prob(gen) < acceptance_prob){
                current_score = new_score;
            } else {
                //revert the move
                placements[node] = make_pair(old_x, old_y);
            }
        }

        //cool down
        heat *= this->cooling_rate;
    }

    return count;
};

void circuit::output(char *filename){
    std::ofstream outfile(filename);
    if (!outfile) {
        std::cerr << "Error opening file for writing: " << filename << std::endl;
        return;
    }

    for (int i = 0; i < placements.size(); ++i) {
        outfile << "Node " << i << " Placed at (" << placements[i].first << ", " << placements[i].second << ")\n";
    }

    for (int i = 0; i < edges.size(); ++i) {
        outfile << "Edge from Node " << edges[i].first << " to Node " << edges[i].second << " has length " 
                << distance(edges[i].first, edges[i].second) << "\n";
    }

    outfile.close();
}

double circuit::total_distance() {
    double total_distance = 0;

    for (int i = 0; i < edges.size(); ++i) {
        total_distance += distance(edges[i].first, edges[i].second);
    }

    return total_distance;
}
