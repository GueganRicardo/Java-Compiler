#include "structs_arvore.h"

struct nomes{
	char * nome;
	struct nomes *next;
};

struct variavel{
	struct nomes *nome;
	struct nomes *parametros;
	struct nomes * type;
	struct variavel *next;
};

struct tabela{
	struct nomes *nome;
	struct nomes *types_params;
	struct variavel *var;
	struct tabela *next;
};

void controi_tabela_global(struct no *inicio);

void controi_tabela(struct no *inicio);

struct tabela *cria_tabela(char *nome);

void add_var(struct tabela *alvo,struct no* new_var);

void add_param(struct tabela *alvo,struct no* param);

void add_metodo(struct no* inicio);

void imprime_tabela(struct tabela *tab_global);

