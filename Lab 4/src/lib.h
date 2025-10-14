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

        circuit();
        void read_file(char *filename);
        void anneal();
        void init_placement();
        void output(char *filename);


    private:
    //address = id, content = <x,y>
        vector<pair<int,int>> placements;

        double distance(int n1, int n2);
        double score();
        bool is_used(int x, int y);

};

#endif