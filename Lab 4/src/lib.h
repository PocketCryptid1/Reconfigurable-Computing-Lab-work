//include gaurd
#ifndef _Lib_Header_
#define _Lib_Header_

using namespace std;

class circuit{
    public:
        int grid_x;
        int grid_y;
        int num_nodes;
        std::pair<int,int> *edges;
        circuit();
        void read_file(char *filename);

    private:
        int **grid;
};

#endif