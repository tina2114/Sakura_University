#include <iostream>
#include "head/stl_vector.h"

zhz_stl::vector<int> ve;
auto a = ve.begin();
int main() {
    for (int i =0;i<5;a++)
        i++;
    ve.insert(a,5);
}