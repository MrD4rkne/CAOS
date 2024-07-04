#include <iostream>
#include <vector>
#include <random>
#include <cassert>
#include <set>

using namespace std;

mt19937 rng(0);

int randint(int a, int b) {
    assert(a <= b);
    return a + rng() % (b - a + 1);
}

set<int>::iterator random_choice(set<int>&s) {
    if(s.size() == 0)
        return s.end();
    auto it = s.begin();
    advance(it, randint(0, (int)s.size() - 1));
    return it;
}

int main(int argc, char **argv) {
    if(argc >= 2) {
        rng = mt19937(stoi(argv[1]));
    }
    
    int n = randint(0, 6);
    int q = randint(5, 10'000);
    cout << n << " " << q << "\n";
    
    set<int>active_gates;
    vector<int>inputs;
    
    int queries = 0;
    
    while(queries < q) {
        int op = randint(1, 7);
        
        if(op == 1) {
            active_gates.insert(inputs.size());
            inputs.push_back(randint(0, 2));
            cout << op << " " << inputs.back() << "\n";
            queries++;
        } else if(op == 2) {
            if(active_gates.size() >= 1) {
                auto it = random_choice(active_gates);
                cout << op << " " << *it << "\n" << flush;
                active_gates.erase(it);
                queries++;
            }
        } else if(op == 3) {
            if(active_gates.size() >= 1) {
                auto ix = random_choice(active_gates);
                auto iy = random_choice(active_gates);
                
                if(inputs[*iy] > 0) {
                    cout << op << " " << *ix << " " << *iy << " " << randint(0, inputs[*iy] - 1) << "\n";
                    queries++;
                }
            }
        } else if(op == 4) {
            if(n >= 1 && active_gates.size() >= 1) {
                auto iy = random_choice(active_gates);
                int x = randint(0, n - 1);
                if(inputs[*iy] > 0) {
                    cout << op << " " << x << " " << *iy << " " << randint(0, inputs[*iy] - 1) << "\n";
                    queries++;
                }
            }
        } else if(op == 5) {
            if(active_gates.size() >= 1) {
                int k = randint(1, (int)active_gates.size());
                cout << op << " " << k << " ";
                for(int i = 0; i < k; i++)
                    cout << *random_choice(active_gates) << " ";
                cout << "\n";
                queries++;
            }
        } else if(op == 6) {
            if(active_gates.size() >= 1) {
                auto it = random_choice(active_gates);
                cout << op << " " << *it << "\n";
                queries++;
            }
        } else if(op == 7) {
            if(active_gates.size() >= 1) {
                auto it = random_choice(active_gates);
                cout << op << " " << *it << "\n";
                queries++;
            }
        }
        
        cout << flush;
    }
    
}
