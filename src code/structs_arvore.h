#include <stdio.h>
#include <string.h>
#include <stdlib.h>

struct no{
char * valor;
char * tipo;
int linha;
int coluna;
struct no * filho;
struct no * next;
};

struct trio {
    char * value;
    int linha;
    int coluna;
};

void add_new (struct no* anterior,struct  no* novo);

void add_son (struct no* pai,struct  no* novo);

struct no * create_new_node(char * valor, int linha, int coluna);

void print_arvore(struct no* inicio, int camada);

void esvazia_arvore(struct no* inicio);

int tem_filhos_interessantes(struct no* pai);
