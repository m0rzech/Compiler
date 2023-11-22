
enum code_ops
{
    komenda_HALT,    komenda_READ,    komenda_WRITE,    komenda_LOAD,    komenda_STORE,    komenda_ADD,    komenda_SUB,    komenda_SET,    komenda_JUMP,    komenda_JZ,    komenda_JGE, komenda_DATA
};

char *op_name[] = {
    "HALT",    "READ",    "WRITE",    "LOAD",    "STORE",    "ADD",    "SUB",    "SET",    "JUMP",    "JZ",    "JGE",    ""
};
struct instruction
{
    enum code_ops op;
    int arg;
};

struct instruction code[999];
int stack[999];
