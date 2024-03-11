#include "semantica.h"
extern struct tabela *t_global;
struct tabela *atual;
int active = 0; 


static char caso[][32] = {
						"int", "int", "int", "",
						"double", "double", "double", "",
						"boolean", "boolean", "undef", "E",	
						"int", "undef", "undef", "E",
						"int", "boolean", "undef", "E",
						"int", "double", "double", "",
						"boolean", "double", "undef", "E",
						"boolean", "undef", "undef", "E",
						"double", "undef", "undef", "E",
						"undef", "undef", "undef", "E"
						"String[]", "int", "undef", "E",
						"String[]", "boolean", "undef", "E",
						"String[]", "double", "undef", "E",
						"String[]", "undef", "undef", "E",
						"String[]", "String[]", "undef", "E"
						};

int check_out_of_bounds (char * orig) { // recebe char * com "2___6769"... retorna 1 se for para dar erro
    char str[256] = "";
    strcpy(str, orig);
    const char s[2] = "_";
    char * token;
    char dest[1000] = "";

    /* get the first token */
    token = strtok(str, s);

    /* walk through other tokens */
    while( token != NULL ) {
        strcat(dest, token);
        token = strtok(NULL, s);
    }
    // aqui temos de ter a string sem underscores
    char * aux = "2147483648";
    if (strlen(dest) > strlen(aux)) {
        return 1;
    }
    if (strlen(dest) == strlen(aux) && strcmp(dest, aux) >= 0) {
        return 1;
    }
    return 0;
}

char * corta_id (char * input){
	char * output;
	output = strdup(input);
	output = output+3;
	output[strlen(output)-1] = '\0';
	return output;
}

char * corta_declit (char * input){
    char * output;
    output = strdup(input);
    output = output+7;
    output[strlen(output)-1] = '\0';
    return output;
}


void tratar_par_expr(struct no * exprboy, char * symbol){
	active = 1;
	controi_tabela(exprboy->filho);
	controi_tabela(exprboy->filho->next);	
	char * tipo1 = exprboy->filho->tipo;
	char * tipo2 = exprboy->filho->next->tipo;
	if ((strcmp(tipo1,"int")!=0&&strcmp(tipo1,"double")!=0)||(strcmp(tipo2,"int")!=0&&strcmp(tipo2,"double")!=0)){
		exprboy->tipo = "undef";
		printf("Line %d, col %d: Operator %s cannot be applied to types %s, %s\n", exprboy->linha, exprboy->coluna, symbol, tipo1, tipo2);
	}
	else {
		if (strcmp(tipo1,"double")==0 || strcmp(tipo2,"double")==0)
			exprboy->tipo = "double";
		else
			exprboy->tipo = "int";
	}
}
			



void tratar_par_expr_comp(struct no * exprboy, char * symbol, int aceita_2_bools){ //no == e != chamar com aceita=1
	active = 1;
	controi_tabela(exprboy->filho);
	controi_tabela(exprboy->filho->next);
	char * tipo1 = exprboy->filho->tipo;
	char * tipo2 = exprboy->filho->next->tipo;
	if (aceita_2_bools && strcmp(tipo1,"boolean")==0 && strcmp(tipo2,"boolean")==0) exprboy->tipo = "boolean"; 
	else if (!aceita_2_bools && strcmp(tipo1,"boolean")==0 && strcmp(tipo2,"boolean")==0) { //nao aceitava 2 bools
		exprboy->tipo = "undef";
		printf("Line %d, col %d: Operator %s cannot be applied to types %s, %s\n", exprboy->linha, exprboy->coluna, symbol, tipo1, tipo2);
	}
	else if (strcmp(tipo1,"undef")==0||strcmp(tipo2,"undef")==0) { //um é undef
		exprboy->tipo = "undef"; // se um for undef fica undef
		printf("Line %d, col %d: Operator %s cannot be applied to types %s, %s\n", exprboy->linha, exprboy->coluna, symbol, tipo1, tipo2);
	}
	else if (strcmp(tipo1, tipo2)==0 && (strcmp(tipo1,"int")==0||strcmp(tipo1,"double")==0)) exprboy->tipo = "boolean"; 				  // int int, double double
	else if ((strcmp(tipo1,"int")==0&&strcmp(tipo2,"double")==0)||(strcmp(tipo1,"double")==0&&strcmp(tipo2,"int")==0)) exprboy->tipo = "boolean"; //1 int 1 double 
	else {
		exprboy->tipo = "boolean";
		printf("Line %d, col %d: Operator %s cannot be applied to types %s, %s\n", exprboy->linha, exprboy->coluna, symbol, tipo1, tipo2);
	}
}


void tratar_while_if(struct no * boy, char * _case_) {
    active = 1;
    controi_tabela(boy->filho);
    controi_tabela(boy->filho->next);
    char * tipo1 = boy->filho->tipo;
    if (strcmp(_case_,"if")==0) {
    	controi_tabela(boy->filho->next->next);
    }
    if (strcmp(tipo1,"boolean")!=0) printf("Line %d, col %d: Incompatible type %s in %s statement\n", boy->filho->linha, boy->filho->coluna, tipo1, _case_);
}

void tratar_shifts(struct no * shiftboy, char * symbol) {
    active = 1;
    controi_tabela(shiftboy->filho);
    controi_tabela(shiftboy->filho->next);
    char * tipo1 = shiftboy->filho->tipo;
    char * tipo2 = shiftboy->filho->next->tipo;
    if (strcmp(tipo1,"int")==0&&strcmp(tipo2,"int")==0) shiftboy->tipo = "int";
    else {
        shiftboy->tipo = "undef";
        printf("Line %d, col %d: Operator %s cannot be applied to types %s, %s\n", shiftboy->linha, shiftboy->coluna, symbol, tipo1, tipo2);
    }
}


char * anota_metodo(struct no *metodo, struct nomes *tipo_params){ 
	char resultado[300] = "(";
    int vezes_que_encontrei = 0;
    int bom_match=0;
    struct variavel *nova;
    struct nomes *params;
    struct nomes *auxiliar = tipo_params;
    struct nomes *auxiliar_final;
    nova = t_global->var;
    char *retorno=NULL;
    while(nova!=NULL){
        if(strcmp(corta_id(metodo->valor),nova->nome->nome)==0){
        	auxiliar = tipo_params;
            params = nova->parametros;
            if ((auxiliar->nome == NULL) && (params->nome == NULL)) {
               	vezes_que_encontrei++;
               	retorno = nova->type->nome;
               	auxiliar_final=nova->parametros;
            }
            else {
            	while(auxiliar->next != NULL && params!= NULL) {
            		//printf("a testar\n");
            		if (auxiliar->nome == NULL || params->nome == NULL) break;
            		if(strcmp(auxiliar->nome, params->nome)==0) {
            			auxiliar = auxiliar->next;
            			params = params->next;
            			if (auxiliar->nome == NULL && params == NULL) {
            				bom_match++;
            				vezes_que_encontrei++;
            				auxiliar_final=nova->parametros;
		        			if(bom_match==1){
		        				vezes_que_encontrei=1;
		        			}
            				retorno = nova->type->nome;
            				break;
            			}
            		}else if((!strcmp(auxiliar->nome,"int")&&!strcmp(params->nome,"double"))&&!bom_match){
            			auxiliar = auxiliar->next;
            			params = params->next;
            			if (auxiliar->nome == NULL && params == NULL) {
            				vezes_que_encontrei++;
            				auxiliar_final=nova->parametros;
            				retorno = nova->type->nome;
            				break;
            			}
            		}
            		else {
            			break;
            		}
            	}
            }
        }
        nova=nova->next;
    }
    if (vezes_que_encontrei==0){
    printf("Line %d, col %d: Cannot find symbol %s\n", metodo->linha, metodo->coluna, corta_id(metodo->valor));
    retorno = "undef";
    }
    else if (vezes_que_encontrei > 1){
	printf("Line %d, col %d: Reference to method %s is ambiguous\n", metodo->linha, metodo->coluna, corta_id(metodo->valor));
    retorno = "undef";
    }
    auxiliar = auxiliar_final;
    while (1) {
    	if (auxiliar->nome ==NULL) break;
    	strcat(resultado,auxiliar->nome);
    	if (auxiliar->next == NULL || auxiliar->next->nome==NULL) break;
    	strcat(resultado,",");
    	auxiliar = auxiliar->next;
    }
    strcat(resultado, ")");
    resultado[strlen(resultado)] = '\0';
    metodo->tipo= strdup(resultado);
    return retorno;
}


void tratar_call(struct no *call){
	active = 1;
	struct no *nova = (struct no*)malloc(sizeof(struct no));
	struct nomes *tipo_params=(struct nomes*)malloc(sizeof(struct nomes));
	struct nomes *aux=tipo_params;
	tipo_params->nome=NULL;
	tipo_params->next=NULL;
	controi_tabela(call->filho);// tem de ser algo para dar match
	nova=call->filho->next;
	while(nova!=NULL){
		controi_tabela(nova);
		aux->nome=nova->tipo;
		nova=nova->next;
		aux->next=(struct nomes*)malloc(sizeof(struct nomes));
		aux=aux->next;
	}
	aux=NULL;
	for(aux=tipo_params;aux->next!=NULL;aux=aux->next){//condicao para obter os tipos corretos
	}
	call->tipo=anota_metodo(call->filho,tipo_params);
}


void tratar_bools(struct no *booliboy, char * symbol);

void tratar_solo_expr(struct no * exprboy, char * symbol);

char * consulta_tabela(char * id);


void controi_tabela(struct no *inicio){
	int n_entrei =1;
	if (inicio->tipo != NULL) return;
	if(strcmp(inicio->valor,"Program")==0){
		atual=t_global;
	}
	else if(strcmp(inicio->valor,"MethodHeader")==0){
		atual=atual->next;
		active = 0;
	}
	else if(strcmp(inicio->valor,"FieldDecl")==0){
		active = 0;
	}
	else if(strcmp(inicio->valor,"Print")==0){
		active = 1;
		controi_tabela(inicio->filho);	
		char * tipo1 = inicio->filho->tipo;
		if (strcmp(tipo1, "String[]")==0) printf("Line %d, col %d: Incompatible type String[] in System.out.print statement\n", inicio->filho->linha, inicio->filho->coluna);
	}
	else if(strcmp(inicio->valor,"VarDecl")==0){
		add_var(atual,inicio->filho);
		active = 0;
	}
	else if(strcmp(inicio->valor,"While")==0){
		n_entrei =0;
		tratar_while_if(inicio,"while");
	}
	else if(strcmp(inicio->valor,"If")==0){
		n_entrei =0;
		tratar_while_if(inicio,"if");
	}
	//booli boys
	else if(strcmp(inicio->valor,"Eq")==0){
        n_entrei =0;
        tratar_par_expr_comp(inicio, "==", 1);
    }
    else if(strcmp(inicio->valor,"Ge")==0){
        n_entrei =0;
        tratar_par_expr_comp(inicio, ">=", 0);

    }
    else if(strcmp(inicio->valor,"Gt")==0){
        n_entrei =0;
        tratar_par_expr_comp(inicio, ">", 0);
    }
    else if(strcmp(inicio->valor,"Le")==0){
        n_entrei =0;
        tratar_par_expr_comp(inicio, "<=", 0);
    }
    else if(strcmp(inicio->valor,"Lt")==0){
        n_entrei =0;
        tratar_par_expr_comp(inicio, "<", 0);
    }
    else if(strcmp(inicio->valor,"Ne")==0){
        n_entrei =0;
        tratar_par_expr_comp(inicio, "!=", 1);
    }
	else if(strcmp(inicio->valor,"And")==0){
		n_entrei =0;
		tratar_bools(inicio,"&&");
		active = 1;
	}
	else if(strcmp(inicio->valor,"Or")==0){
		n_entrei =0;
		tratar_bools(inicio,"||");
		active = 1;
	}
	else if(strcmp(inicio->valor,"Xor")==0){
		n_entrei =0;
		tratar_bools(inicio,"^");
		active = 1;
	}
	//fim dos booli boys
	//expressoes algébricas
	else if(strcmp(inicio->valor,"Add")==0){
		n_entrei =0;
		tratar_par_expr(inicio, "+");
	}
	else if(strcmp(inicio->valor,"Sub")==0){
		n_entrei =0;
		tratar_par_expr(inicio, "-");
	}
	else if(strcmp(inicio->valor,"Mul")==0){
		n_entrei =0;
		tratar_par_expr(inicio, "*");
	}
	else if(strcmp(inicio->valor,"Div")==0){
		n_entrei =0;
		tratar_par_expr(inicio, "/");
	}
	else if(strcmp(inicio->valor,"Mod")==0){
		n_entrei =0;
		tratar_par_expr(inicio, "%");
	}
	else if(strcmp(inicio->valor,"Lshift")==0){
		n_entrei =0;
		active = 1;
		tratar_shifts(inicio,"<<");
	}
	else if(strcmp(inicio->valor,"Rshift")==0){
		n_entrei =0;
		active = 1;
		tratar_shifts(inicio,">>");
	}
	//fim expressoes algébricas
	// especial
	else if(strcmp(inicio->valor,"ParseArgs")==0){
        active = 1;
        n_entrei =0;
        controi_tabela(inicio->filho);
        controi_tabela(inicio->filho->next);
        char * tipo1 = inicio->filho->tipo;
        char * tipo2 = inicio->filho->next->tipo;
        if (strcmp(tipo1,"String[]")!=0||strcmp(tipo2,"int")!=0){
            printf("Line %d, col %d: Operator Integer.parseInt cannot be applied to types %s, %s\n", inicio->linha, inicio->coluna, tipo1, tipo2);
        }
        inicio->tipo = "int";
    }
	else if(strcmp(inicio->valor,"Length")==0){
        active = 1;
        n_entrei =0;
        controi_tabela(inicio->filho);
        if (strcmp(inicio->filho->tipo, "String[]")!=0){
            printf("Line %d, col %d: Operator .length cannot be applied to type %s\n", inicio->linha, inicio->coluna, inicio->filho->tipo);
        }
        inicio->tipo = "int";
    }
	else if(strcmp(inicio->valor,"Minus")==0){
		//int double undef
		n_entrei = 0;
		tratar_solo_expr(inicio, "-");
	}
	else if(strcmp(inicio->valor,"Plus")==0){
		//int double undef
		n_entrei = 0;
		tratar_solo_expr(inicio, "+");
	}
	else if(strcmp(inicio->valor,"Not")==0){
		active = 1;
		n_entrei =0;
		controi_tabela(inicio->filho);
		if (strcmp(inicio->filho->tipo, "boolean")!=0){
			inicio->tipo = "undef";
			printf("Line %d, col %d: Operator ! cannot be applied to type %s\n", inicio->linha, inicio->coluna, inicio->filho->tipo);
		}
		else inicio->tipo = "boolean";
	}
	else if(strcmp(inicio->valor,"Assign")==0){//fazer o levantamento do erro
		active = 1;
		n_entrei =0;
		controi_tabela(inicio->filho);
		controi_tabela(inicio->filho->next);
		char * tipo1 = inicio->filho->tipo;
		char * tipo2 = inicio->filho->next->tipo;
		if (strcmp(tipo1,tipo2)==0);
		else if (strcmp(tipo1,"double")==0&&strcmp(tipo2,"int")==0);
		else printf("Line %d, col %d: Operator = cannot be applied to types %s, %s\n", inicio->linha, inicio->coluna, tipo1, tipo2);
		inicio->tipo = strdup(tipo1);
	}
	else if(strcmp(inicio->valor,"Call")==0){
		tratar_call(inicio);
	}
	if (strlen(inicio->valor)>6){
		char * auxiliar_lit;
		auxiliar_lit = strdup(inicio->valor);
		auxiliar_lit[6] = '\0';
		if(strcmp(auxiliar_lit,"DecLit")==0){
            n_entrei =0;
            inicio->tipo="int";
            if (check_out_of_bounds(corta_declit(inicio->valor))) printf("Line %d, col %d: Number %s out of bounds\n", inicio->linha, inicio->coluna, corta_declit(inicio->valor));
        }
		else if(strcmp(auxiliar_lit,"RealLi")==0){
			n_entrei =0;
			inicio->tipo="double";
		}  
		else if(strcmp(auxiliar_lit,"BoolLi")==0){
			n_entrei =0;
			inicio->tipo="boolean";
		}  
		else if(strcmp(auxiliar_lit,"StrLit")==0){
			n_entrei =0;
			inicio->tipo="String";
		} 
	}
	if (strlen(inicio->valor)>4) {
		char * auxiliar_id; // para guardar o id cujo tipo precisamos de determinar
		auxiliar_id = strdup(inicio->valor);
		auxiliar_id[3] = '\0';
		if (strcmp(auxiliar_id,"Id(")==0 && active) {
			auxiliar_id = strdup(inicio->valor);
			auxiliar_id[strlen(auxiliar_id)-1] = '\0';
			auxiliar_id = auxiliar_id+3;
			inicio->tipo = consulta_tabela(auxiliar_id);
			if (strcmp(inicio->tipo,"undef")==0) printf("Line %d, col %d: Cannot find symbol %s\n", inicio->linha, inicio->coluna, auxiliar_id);
		}
	}
	if(inicio->filho!=NULL&&n_entrei){
		controi_tabela(inicio->filho);
	}
	if(inicio->next!=NULL){
		controi_tabela(inicio->next);
	}
}


void tratar_bools(struct no *booliboy, char * symbol){
    active = 1;
    controi_tabela(booliboy->filho);
    controi_tabela(booliboy->filho->next);
    char * tipo1 = strdup(booliboy->filho->tipo);
    char * tipo2 = booliboy->filho->next->tipo;
    if (strcmp(symbol,"^")==0 && strcmp(tipo1,"int")==0&&strcmp(tipo2,"int")==0){
    	booliboy->tipo="int";
    	return;
    }
    if (strcmp(tipo1,"boolean")!=0||strcmp(tipo2,"boolean")!=0){
        booliboy->tipo="undef";
        printf("Line %d, col %d: Operator %s cannot be applied to types %s, %s\n", booliboy->linha, booliboy->coluna, symbol, tipo1, tipo2);
    }
    else booliboy->tipo="boolean";
}


void tratar_solo_expr(struct no * exprboy, char * symbol){
	active = 1;
	controi_tabela(exprboy->filho);
	if (strcmp(exprboy->filho->tipo, "double")==0 || strcmp(exprboy->filho->tipo, "int")==0) exprboy->tipo = strdup(exprboy->filho->tipo); 
	else {
		strcpy(exprboy->tipo, "undef");
		printf("Line %d, col %d: Operator %s cannot be applied to type %s\n", exprboy->linha, exprboy->coluna, symbol, exprboy->filho->tipo);
	}
}


void controi_tabela_global(struct no *inicio){
	if(strcmp(inicio->valor,"Program")==0){
		//fazer bem o print da class
		t_global=cria_tabela(inicio->filho->valor);
		atual=t_global;
	}
	else if(strcmp(inicio->valor,"FieldDecl")==0){
		atual=t_global;
		add_var(t_global,inicio->filho);
	}
	else if(strcmp(inicio->valor,"MethodHeader")==0){
		add_metodo(inicio->filho);
	}
	else if(strcmp(inicio->valor,"ParamDecl")==0){
		add_param(atual,inicio->filho);
	}
	if(inicio->filho!=NULL){
		controi_tabela_global(inicio->filho);
	}
	if(inicio->next!=NULL){
		controi_tabela_global(inicio->next);
	}
}


void use_correct_type(struct nomes *info){
	if(strcmp("StringArray",info->nome)==0){
		info->nome="String[]";
	}
	else if(strcmp("Int",info->nome)==0){
		info->nome="int";
	}
	else if(strcmp("Double",info->nome)==0){
		info->nome="double";
	}
	else if(strcmp("Bool",info->nome)==0){
		info->nome="boolean";
	}
	else if(strcmp("Void",info->nome)==0){
		info->nome="void";
	}
	else if(strcmp("Return",info->nome)==0){ // este nem sei se é preciso
		info->nome="return";
	}
}


char * check_id_alter(char * string, char * aux_string){
	char *nova;
	nova = strdup(string);
    if (strlen(nova) <= 4) return nova;
    strcpy(aux_string, nova);
    aux_string[3] = '\0';
    if(strcmp(aux_string,"Id(")!=0) return nova;
    nova = nova+3;
    const char s[2] = ")";
    strtok(nova, s);
    return nova;
}


char * consulta_tabela(char * id){
	struct variavel * aux;
	if (atual->var != NULL) {
		aux = atual->var;
		while (aux != NULL) {
			if (strcmp(aux->nome->nome, id)==0) return aux->type->nome;
			aux = aux->next;
		}
	}
	if (t_global->var != NULL) {
		aux = t_global->var;
		while (aux != NULL) {
			if (strcmp(aux->nome->nome, id)==0) return aux->type->nome;
			aux = aux->next;
		}
	}
	return "undef";
}


struct tabela *cria_tabela(char *nome){
	struct tabela *nova=(struct tabela*)malloc(sizeof(struct tabela));
	struct nomes *new_nome = (struct nomes*)malloc(sizeof(struct nomes));
	char aux[1024];
	new_nome->nome=check_id_alter(nome,aux);
	nova->nome=new_nome;
	nova->var=NULL;
	nova->next=NULL;
	if(t_global!=NULL){
		struct tabela *aux=t_global->next;
		if(aux!=NULL){
			while(aux->next!=NULL){
				aux=aux->next;
			}
			aux->next=nova;
		}else{
			t_global->next=nova;
		}
	}
	return nova;
}


void add_var(struct tabela *alvo,struct no* new_var){
	struct variavel *nova = (struct variavel*)malloc(sizeof(struct variavel));
	struct nomes *nome = (struct nomes*)malloc(sizeof(struct nomes));
	struct nomes *tipo = (struct nomes*)malloc(sizeof(struct nomes));
	char auxi[1024];
	nova->nome=nome;
	nova->type=tipo;
	tipo->nome=new_var->valor;
	use_correct_type(tipo); 
	nome->nome=check_id_alter(new_var->next->valor,auxi);
	tipo->next=NULL;
	nome->next=NULL;
	nova->parametros=NULL;
	nova->next=NULL;
	//encontrar onde colocar
	struct variavel *aux = alvo->var;
	if(aux==NULL){
		 alvo->var=nova;
	}else{
		while(aux->next!=NULL){
			aux=aux->next;
		}
		aux->next=nova;
	}
}


void add_metodo_param(struct tabela *alvo,struct nomes* param){
	struct variavel *aux = (struct variavel*)malloc(sizeof(struct variavel));
	aux=t_global->var;
	while(aux->next!=NULL){
		aux=aux->next;
	}
	aux->parametros=param;
}


void add_param(struct tabela *alvo,struct no* param){
	//adiciona o parametro
	struct nomes *tipo_p = (struct nomes*)malloc(sizeof(struct nomes));
	struct nomes *aux_x=alvo->types_params;
	tipo_p->nome=param->valor;
	use_correct_type(tipo_p);
	if(aux_x==NULL){
		alvo->types_params=tipo_p;
		add_metodo_param(alvo,tipo_p);
	}else{
		while(aux_x->next!=NULL){
			aux_x=aux_x->next;
		}
		aux_x->next=tipo_p;
	}
	struct variavel *nova = (struct variavel*)malloc(sizeof(struct variavel));
	struct nomes *nome = (struct nomes*)malloc(sizeof(struct nomes));
	struct nomes *tipo = (struct nomes*)malloc(sizeof(struct nomes));
	struct nomes *params = (struct nomes*)malloc(sizeof(struct nomes));
	char *auxu="param";
	char auxi[1024];
	nova->nome=nome;
	nova->type=tipo;
	tipo->nome=param->valor;
	use_correct_type(tipo);
	nome->nome=check_id_alter(param->next->valor,auxi);
	tipo->next=NULL;
	nome->next=NULL;
	params->nome=auxu;
	nova->parametros=params;
	params->next=NULL;
	nova->next=NULL;
	//encontra onde colocar
	struct variavel *aux = alvo->var;
	if(aux==NULL){
		 alvo->var=nova;
	}else{
		while(aux->next!=NULL){
			aux=aux->next;
		}
		aux->next=nova;
	}
}


void add_metodo(struct no* inicio){
	//nova tabela
	atual=cria_tabela(inicio->next->valor);
	struct variavel *retorno= (struct variavel*)malloc(sizeof(struct variavel));
	struct nomes *nome = (struct nomes*)malloc(sizeof(struct nomes));
	struct nomes *tipo = (struct nomes*)malloc(sizeof(struct nomes));
	retorno->nome=nome;
	retorno->type=tipo;
	retorno->parametros=NULL;
	retorno->next=NULL;
	char *aux="return";
	nome->nome=aux;
	tipo->nome=inicio->valor;
	use_correct_type(tipo);
	atual->var=retorno;
	//add á tabela global
	struct variavel *new_func = (struct variavel*)malloc(sizeof(struct variavel));
	struct nomes *nome_newmetod = (struct nomes*)malloc(sizeof(struct nomes));
	struct nomes *tipo_newmetod = (struct nomes*)malloc(sizeof(struct nomes));
	struct nomes *params_newmetod = (struct nomes*)malloc(sizeof(struct nomes));
	new_func->nome=nome_newmetod;
	new_func->parametros=params_newmetod;
	params_newmetod->nome=NULL;
	new_func->type=tipo_newmetod;
	new_func->next=NULL;
	tipo_newmetod->nome=atual->var->type->nome;
	use_correct_type(tipo_newmetod);
	nome_newmetod->nome=atual->nome->nome;
	//encontra onde dar ad
	struct variavel *auxz = t_global->var;
	if(auxz==NULL){
		 t_global->var=new_func;
	}else{
		while(auxz->next!=NULL){
			auxz=auxz->next;
		}
		auxz->next=new_func;
	}
}

int unique_tab(struct tabela *tabeli){
	struct tabela *aux=t_global->next;
	struct nomes *aux_nome1;
	struct nomes *aux_nome2;
	while(aux!=NULL){
		if(strcmp(tabeli->nome->nome,aux->nome->nome)==0){
			aux_nome1=aux->types_params;
			aux_nome2=tabeli->types_params;
			 if ((aux_nome1 == NULL) && (aux_nome2 == NULL)) {
			 		return 0;
			 }

            else {
            	while(aux_nome1 != NULL && aux_nome2!= NULL) {
            		if (aux_nome1->nome == NULL || aux_nome2->nome == NULL) break;
            		if(strcmp(aux_nome1->nome, aux_nome2->nome)==0) {
            			aux_nome1 = aux_nome1->next;
            			aux_nome2 = aux_nome2->next;
            			if (aux_nome1 == NULL && aux_nome2 == NULL) {
            				return 0;
            			}
            		}
            		else {
            			break;
            		}
            	}
            }
        }
		aux=aux->next;
	}
	return 1;
}

void aux_imprime_tabelas(struct tabela *tabelas, int n_tabelas){
	if(tabelas==NULL){
		return;
	}
	//impressao do titulo
	//if(unique_tab(tabelas)){
		printf("===== Method %s(", tabelas->nome->nome);
		struct nomes *aux=tabelas->types_params;
		if(aux!=NULL){	
			printf("%s",aux->nome);
			aux=aux->next;
			while(aux!=NULL){
				printf(",%s",aux->nome);
				aux=aux->next;
			}
			printf(") ");
		}else{
			printf(") ");
		}
		printf("Symbol Table =====\n");
		//impressao variaveis
		struct variavel *var=tabelas->var;
		while(var!=NULL){
			struct nomes *nome=var->nome;
			printf("%s		",var->nome->nome);
			printf("%s",var->type->nome);
			//imprime paramaetros
			if(var->parametros!=NULL){
				printf("	%s",var->parametros->nome);
			}
			printf("\n");
			var=var->next;
		}
		printf("\n");
	//}
	n_tabelas++;
	aux_imprime_tabelas(tabelas->next,n_tabelas);
}


void imprime_tabela(struct tabela *tab_global){
	//impressao do titulo
	printf("===== Class %s Symbol Table =====\n", tab_global->nome->nome);
	//impressao variaveis
	struct variavel *var=tab_global->var;
	while(var!=NULL){
		struct nomes *nome=var->nome;
		printf("%s	",nome->nome);
		//imprime paramaetros
		if(var->parametros!=NULL){
			nome=var->parametros;
			if(nome->nome==NULL){
				printf("(");
			}else{
			printf("(%s",nome->nome);
		}
			nome=nome->next;
			while(nome!=NULL){
				printf(",%s",nome->nome);
				nome=nome->next;
			}
			printf(")");
		}
		printf("	");
		printf("%s\n",var->type->nome);
		var=var->next;
	}
	printf("\n");
	aux_imprime_tabelas(tab_global->next,1);
}
