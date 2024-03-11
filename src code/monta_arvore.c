#include "structs_arvore.h"

void add_new (struct no* anterior,struct no* novo){
if (anterior==NULL) {anterior=novo; return;}
struct no * aux;
for (aux=anterior;aux->next!=NULL;aux=aux->next);
aux->next=novo;
return;
}

void add_son (struct no* pai,struct no* novo){
pai->filho=novo;
}

struct no * create_new_node(char * valor, int linha, int coluna){
	struct no *novo =(struct no*)malloc(sizeof(struct no));
	novo->tipo = NULL;
	novo->valor=strdup(valor);
	novo->linha = linha;
	novo->coluna = coluna;
	novo->next=NULL;
	novo->filho=NULL;
	return novo;
}

void print_arvore(struct no* inicio, int camada){
	if (strcmp(inicio->valor,"")==0) return;
	for (int i = 0; i < camada; i++) printf("..");

	printf("%s",inicio->valor);
	if (inicio->tipo != NULL) printf(" - %s", inicio->tipo);
	printf("\n");
	if(inicio->filho!=NULL){
		struct no *aux;
		for(aux=inicio->filho;aux!=NULL;aux=aux->next){
			print_arvore(aux, camada+1);
		}
	}
}

void esvazia_arvore(struct no* inicio){
    if(inicio->filho!=NULL){
        struct no *aux;
        for(aux=inicio->filho;aux!=NULL;aux=aux->next){
            esvazia_arvore(aux);
        }
    }
    free(inicio);
} 

int tem_filhos_interessantes(struct no* pai){
	if (pai == NULL || strcmp(pai->valor,"Block")!=0) return 1; // nao tem mas é comos e tivesse
	int resultado = 0;
	struct no * aux = pai;
	for (aux=pai;aux->next!=NULL;aux=aux->next) {
		if(strcmp(aux->valor,"Block")!=0) {resultado = 1;}
		break;
	}
	return resultado;
}




