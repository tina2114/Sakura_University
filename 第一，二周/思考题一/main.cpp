#include <iostream>
#include<vector>
#include<list>
#include<deque>
#include <queue>
#include <stack>
#include<cstdio>
#include<cstdlib>
#include<unistd.h>
#include<cstring>
using namespace::std;
//g++ -z noexecstack -fstack-protector-all -z now -fPIE -pie -s -o source source.cpp
class Test
{
public:
    char* data;
    //构造函数
    Test()
    {
        data = NULL;
    }
    Test(const Test& obj) {
        if(obj.data) {
            data = (char*)malloc(0x98);
            memcpy(data, obj.data, 0x98);
        }
    }
    // 析构函数
    ~Test(){
        free(data);
    }
    void Init()
    {
        data = (char*)malloc(0x98);
        printf("input data:");
        read(0, data, 0x98);
    }
};

list<Test>* mList;
vector<Test>* mVector;
queue<Test>* mQueue;
stack<Test>* mStack;

unsigned int init()
{
    setbuf(stdin, NULL);
    setbuf(stdout, NULL);
    setbuf(stderr, NULL);
    mList = new list<Test>;
    mVector = new vector<Test>;
    mQueue = new queue<Test>;
    mStack = new stack<Test>;
    Test a;
    for (int i=0;i<=1;i++)
    {
        mList->push_back(a);
        mVector->push_back(a);
        mQueue->push(a);
        mStack->push(a);
    }
    for (int j=0;j<=1;j++)
    {
        mList->pop_back();
        mVector->pop_back();
        mQueue->pop();
        mStack->pop();
    }
}

void menu()
{
    puts("STL Container Test");
    puts("1. list");
    puts("2. vector");
    puts("3. queue");
    puts("4. stack");
    puts("5. exit");
    printf(">> ");
}

int get_num()
{
    char buf[8];
    int a = read(0,buf,0x7);
    buf[a] = '\0';
    return atoi(buf);
}

int submenu()
{
    puts("1. add");
    puts("2. delete");
    puts("3. show");
    printf(">> ");
}

void TestList()
{
    submenu();
    int choice = get_num();
    switch(choice)
    {   //add
        case 1:
        {
            if (mList->size() > 1)
            {
                puts("full!");
                return;
            }
            Test a;
            a.Init();
            mList->push_back(a);
            puts("done!");
        }
        break;
            //free
        case 2:
        {
            puts("index?");
            unsigned int index = get_num();
            if (index >= mList->size())
            {
                puts("invalid index!");
                return;
            }
            else
            {
                auto b =  mList->begin();
                for (int i=0;index >i;i++)
                    b++;
                mList->erase(b);
                puts("done!");
            }
        }
            break;
            //show
        case 3:
        {
            puts("index?");
            unsigned int index = get_num();
            if(index >=mList->size())
            {
                puts("invalid index!");
                return;
            }
            else
            {
                auto b = mList->begin();
                for (int i=0;index >i;i++)
                    b++;
                printf("data: %s\n",b->data);
            }
        }
            break;
        default:
            puts("invalid choice!");
    }
}

void TestVector()
{
    submenu();
    int choice = get_num();
    switch(choice)
    {   //add
        case 1:
        {
            if (mVector->size() > 1)
            {
                puts("full!");
                return;
            }
            else
            {
                Test a;
                a.Init();
                mVector->push_back(a);
                puts("done!");
            }
        }
            break;
            //free
        case 2:
        {
            puts("index?");
            unsigned int index = get_num();
            if (index > mVector->size())
            {
                puts("invalid index!");
                return;
            }
            else
            {
                auto b =  mVector->begin();
                for (int i=0;index >i;i++)
                    b++;
                mVector->erase(b);
                puts("done!");
            }
        }
            break;
            //show
        case 3:
        {
            puts("index?");
            unsigned int index = get_num();
            if(index >mVector->size())
            {
                puts("invalid index!");
                return;
            }
            else
            {
                auto b = mVector->begin();
                for (int i=0;index >i;i++)
                    b++;
                printf("data: %s\n",b->data);
            }
        }
            break;
        default:
            puts("invalid choice!");
    }
}

void TestQueue()
{
    submenu();
    int choice = get_num();
    switch(choice)
    {   //add
        case 1:
        {
            if (mQueue->size() >1 )
            {
                puts("full!");
                return;
            }
            else
            {
                Test a;
                a.Init();
                mQueue->push(a);
                puts("done!");
            }
        }
            break;
            //free
        case 2:
        {
            if (mQueue->size()!=0)
                mQueue->pop();
            else
                puts("empty!");
            puts("done!");
        }
            break;
            //show
        case 3:
            puts("not supported!");
            break;
        default:
            puts("invalid choice!");
    }
}

void TestStack()
{
    submenu();
    int choice = get_num();
    switch(choice)
    {   //add
        case 1:
        {
            if (mStack->size() >1)
            {
                puts("full!");
                return;
            }
            Test a;
            a.Init();
            mStack->push(a);
            puts("done!");
        }
            break;
            //free
        case 2:
        {
            if (mStack->size()!=0)
                mStack->pop();
            else
                puts("empty!");
            puts("done!");
        }
            break;
            //show
        case 3:
            puts("not supported!");
            break;
        default:
            puts("invalid choice!");
    }
}

int main()
{   init();
    while(1)
    {
        menu();
        int choice = get_num();
        switch(choice)
        {
            case 1:
                TestList();
                break;
            case 2:
                TestVector();
                break;
            case 3:
                TestQueue();
                break;
            case 4:
                TestStack();
                break;
            case 5:
                exit(0);
            default:
                puts("invalid choice");
        }
    }
}

