//include gaurd
#ifndef _Lib_Header_
#define _Lib_Header_

#include <utility>
#include <vector>

using namespace std;


class circuit{
    public:
        int grid_x;
        int grid_y;
        int num_nodes;
        vector<pair<int,int>> edges;

        circuit(double cooling_rate);
        void read_file(char *filename);
        int anneal();
        void init_placement();
        void output(char *filename);
        double total_distance();


    private:
    //address = id, content = <x,y>
        vector<pair<int,int>> placements;
        const double cooling_rate;

        double distance(int n1, int n2);
        double score();
        bool is_used(int x, int y);

};

#endif