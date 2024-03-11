%{
  #include "semantica.h"

int yylex (void);
int imprimirtree = 1;
void yyerror(char* s);
int flag_debug = 0;
char string_temp[1024];
char type_temp[32];
struct no * paramdecl_temp;
extern struct no *Program;
int counter = 0;
struct no * block_temp;
struct no * aux;
int inside_block = 0; 
%}

// l por yylval
// yacc por nos token <info>
// por os valores no create node

%token COMMA LBRACE LPAR LSQ RBRACE RPAR RSQ SEMICOLON ARROW BOOL CLASS DOUBLE ELSE IF INT PRINT PUBLIC RETURN STATIC VOID WHILE RESERVED STR 

%token <info> STRLIT BOOLLIT REALLIT INTLIT ID PLUS MINUS NOT AND STAR EQ DIV ASSIGN GE GT LE LT MOD NE OR LSHIFT RSHIFT XOR DOTLENGTH PARSEINT



%union{
    struct no *node;
    struct trio *info;
}




%right ELSE IF
%left LBRACE RBRACE RETURN WHILE PRINT RPAR LPAR
%right ASSIGN
%left XOR
%left OR
%left AND
%left EQ NE
%left GE GT LE LT 
%left LSHIFT RSHIFT 
%left PLUS MINUS
%left STAR DIV MOD
%right NOT
%nonassoc error

%type<node>Program MethodDecl FieldDecl Type MethodHeader FormalParams MethodBody VarDecl Statement MethodInvocation Assignment ParseArgs Expr AuxP AuxFD AuxFP AuxMB AuxVD AuxMI BeforeExpr StatementList

%%

Program: CLASS ID LBRACE AuxP RBRACE            {$$=Program=create_new_node("Program", -1,-1); sprintf(string_temp,"Id(%s)",$2->value); add_son($$, create_new_node(strdup(string_temp), $2->linha,$2->coluna)); add_new($$->filho, $4);if(flag_debug) printf("Fim Programa\n");}
    | CLASS ID LBRACE RBRACE            {$$=Program=create_new_node("Program", -1,-1); sprintf(string_temp,"Id(%s)",$2->value); add_son($$, create_new_node(strdup(string_temp), $2->linha,$2->coluna));if(flag_debug) printf("Fim Programa2\n");}
    ;

AuxP: MethodDecl                                {$$=$1;                if(flag_debug)printf("declarar função d %d\n",counter++);}
    | FieldDecl                                 {$$=$1;                if(flag_debug)printf("declarar fielldddd %d\n",counter++);}
    | SEMICOLON                                 {$$=NULL;                      if(flag_debug)printf(";\n");}
    | MethodDecl AuxP                           {$$=$1;add_new($$, $2);if(flag_debug)printf("declarar função -%d\n",counter++);}
    | FieldDecl AuxP                            {$$=$1;add_new($$, $2);if(flag_debug)printf("declarar função ?%d\n",counter++);}
    | SEMICOLON AuxP                            {$$=$2;if(flag_debug)printf(";\n");}
    ;

MethodDecl: PUBLIC STATIC MethodHeader MethodBody   {$$=create_new_node("MethodDecl", -1,-1);add_son($$, $3);add_new($$->filho, $4); if(flag_debug)printf("função criada\n");}

FieldDecl: PUBLIC STATIC Type ID AuxFD SEMICOLON    {$$=create_new_node("FieldDecl", -1,-1);add_son($$, $3);sprintf(string_temp,"Id(%s)",$4->value);add_new($$->filho, create_new_node(strdup(string_temp), $4->linha,$4->coluna)); add_new($$, $5); if(flag_debug)printf("varialveis criadas\n");}
        | PUBLIC STATIC Type ID SEMICOLON           {$$=create_new_node("FieldDecl", -1,-1);add_son($$, $3);sprintf(string_temp,"Id(%s)",$4->value);add_new($$->filho, create_new_node(strdup(string_temp), $4->linha,$4->coluna)); if(flag_debug)printf("varialvei criada\n");}
        | error SEMICOLON {$$=create_new_node("", -1,-1);}
        ;

AuxFD: COMMA ID         {$$=create_new_node("FieldDecl", -1,-1); add_son($$, create_new_node(strdup(type_temp), -1,-1)); sprintf(string_temp,"Id(%s)",$2->value); add_new($$->filho, create_new_node(strdup(string_temp), $2->linha,$2->coluna));}
    | COMMA ID AuxFD    {$$=create_new_node("FieldDecl", -1,-1); add_son($$, create_new_node(strdup(type_temp), -1,-1)); sprintf(string_temp,"Id(%s)",$2->value); add_new($$->filho, create_new_node(strdup(string_temp), $2->linha,$2->coluna)); add_new($$, $3);}
    ;

Type: BOOL {strcpy(type_temp,"Bool"); $$ = create_new_node("Bool", -1,-1);}
    | INT {strcpy(type_temp,"Int"); $$ = create_new_node("Int", -1,-1);}
    | DOUBLE {strcpy(type_temp,"Double"); $$ = create_new_node("Double", -1,-1);}
    ;

MethodHeader: Type ID LPAR FormalParams RPAR            {$$=create_new_node("MethodHeader", -1,-1); add_son($$, $1); sprintf(string_temp,"Id(%s)",$2->value); add_new($$->filho, create_new_node(strdup(string_temp), $2->linha,$2->coluna)); add_new($$->filho, aux=create_new_node("MethodParams", -1,-1)); add_son(aux, $4); if(flag_debug)printf("header da função\n");}
            | Type ID LPAR RPAR                         {$$=create_new_node("MethodHeader", -1,-1); add_son($$, $1); sprintf(string_temp,"Id(%s)",$2->value); add_new($$->filho, create_new_node(strdup(string_temp), $2->linha,$2->coluna)); add_new($$->filho, create_new_node("MethodParams", -1,-1));if(flag_debug)printf("header da função\n");}
            | VOID ID LPAR FormalParams RPAR            {$$=create_new_node("MethodHeader", -1,-1); add_son($$, create_new_node("Void", -1,-1)); sprintf(string_temp,"Id(%s)",$2->value); add_new($$->filho, create_new_node(strdup(string_temp), $2->linha,$2->coluna)); add_new($$->filho, aux=create_new_node("MethodParams", -1,-1)); add_son(aux, $4); if(flag_debug)printf("header da função\n");}
            | VOID ID LPAR RPAR                         {$$=create_new_node("MethodHeader", -1,-1); add_son($$, create_new_node("Void", -1,-1)); sprintf(string_temp,"Id(%s)",$2->value); add_new($$->filho, create_new_node(strdup(string_temp), $2->linha,$2->coluna)); add_new($$->filho, create_new_node("MethodParams", -1,-1));if(flag_debug)printf("header da função\n");}
            
            ;           

FormalParams: Type ID AuxFP {$$=create_new_node("ParamDecl", -1,-1); add_son($$,$1); sprintf(string_temp,"Id(%s)",$2->value); add_new($$->filho, create_new_node(strdup(string_temp), $2->linha,$2->coluna)); add_new($$, $3);}
            | Type ID {$$=create_new_node("ParamDecl", -1,-1); add_son($$, $1); sprintf(string_temp,"Id(%s)",$2->value); add_new($$->filho, create_new_node(strdup(string_temp), $2->linha,$2->coluna));}
            | STR LSQ RSQ ID {$$=create_new_node("ParamDecl", -1,-1); add_son($$, create_new_node("StringArray", -1,-1)); sprintf(string_temp,"Id(%s)",$4->value); add_new($$->filho, create_new_node(strdup(string_temp), $4->linha,$4->coluna));}
            ;

AuxFP: COMMA Type ID  {$$=create_new_node("ParamDecl", -1,-1); add_son($$,$2); sprintf(string_temp,"Id(%s)",$3->value); add_new($$->filho, create_new_node(strdup(string_temp), $3->linha,$3->coluna));}
    | COMMA Type ID AuxFP {$$=create_new_node("ParamDecl", -1,-1); add_son($$,$2); sprintf(string_temp,"Id(%s)",$3->value); add_new($$->filho, create_new_node(strdup(string_temp), $3->linha,$3->coluna)); add_new($$, $4);}
    ;

MethodBody: LBRACE AuxMB RBRACE {$$=create_new_node("MethodBody", -1,-1); add_son($$, $2);}
            | LBRACE RBRACE {$$=create_new_node("MethodBody", -1,-1);}
            ;

AuxMB: Statement                        {$$=$1;if(flag_debug)printf("Statement detro de função\n");}
    | VarDecl                           {$$=$1;if(flag_debug)printf("Declarar variável dentro de função\n");}
    | Statement AuxMB                   {$$=$1;if($$==NULL) $$=$2;else add_new($$,$2);if(flag_debug)printf("Statement1 detro de função\n");}
    | VarDecl AuxMB                     {$$=$1;add_new($$,$2);if(flag_debug)printf("Declarar variável dentro de função\n");}
    ;

VarDecl: Type ID AuxVD SEMICOLON        {$$=create_new_node("VarDecl", -1,-1); add_son($$, $1); sprintf(string_temp,"Id(%s)",$2->value); add_new($$->filho, create_new_node(strdup(string_temp), $2->linha,$2->coluna)); add_new($$,$3); if(flag_debug)printf("a declarar multiplas variáveis\n");}              
        | Type ID SEMICOLON             {$$=create_new_node("VarDecl", -1,-1); add_son($$, $1); sprintf(string_temp,"Id(%s)",$2->value); add_new($$->filho, create_new_node(strdup(string_temp), $2->linha,$2->coluna));if(flag_debug)printf("declarar uma variável\n");}
        ;

AuxVD: COMMA ID AuxVD  {$$=create_new_node("VarDecl", -1,-1); add_son($$, create_new_node(strdup(type_temp), -1,-1)); sprintf(string_temp,"Id(%s)",$2->value); add_new($$->filho, create_new_node(strdup(string_temp), $2->linha,$2->coluna)); add_new($$, $3);}
    | COMMA ID {$$=create_new_node("VarDecl", -1,-1); add_son($$, create_new_node(strdup(type_temp), -1,-1)); sprintf(string_temp,"Id(%s)",$2->value); add_new($$->filho, create_new_node(strdup(string_temp), $2->linha,$2->coluna));}
    ; 

Statement: LBRACE StatementList RBRACE      {if ($2==NULL) $$=create_new_node("Block", -1,-1);                              //caso de 0
                                             else if ($2->next!=NULL) {$$=create_new_node("Block", -1,-1); add_son($$, $2); if(tem_filhos_interessantes($2)==0) $$=NULL;} //caso de 2+
                                             else $$=$2;
                                            }
        | IF LPAR BeforeExpr RPAR Statement ELSE Statement                {$$=create_new_node("If", -1,-1);add_son($$,$3);add_new($$->filho,$5);add_new($$->filho,$7);if(flag_debug)printf("if1\n");}
        | IF LPAR BeforeExpr RPAR Statement %prec ELSE                {$$=create_new_node("If", -1,-1);add_son($$,$3);add_new($$->filho,$5);add_new($$->filho,create_new_node("Block", -1,-1));if(flag_debug)printf("if2\n");}
        | WHILE LPAR BeforeExpr RPAR Statement                {$$=create_new_node("While", -1,-1);add_son($$,$3);if($5==NULL) add_new($$->filho, create_new_node("Block", -1,-1)); else add_new($$->filho,$5); if(flag_debug)printf("invocação de while\n");}
        | RETURN BeforeExpr SEMICOLON             {$$=create_new_node("Return", -1,-1);add_son($$,$2);if(flag_debug)printf("return algo\n");}
        | RETURN SEMICOLON              {$$=create_new_node("Return", -1,-1);if(flag_debug)printf("return nada\n");}
        | MethodInvocation SEMICOLON                     {$$=$1;if(flag_debug)printf("Invocação metodo\n");}
        | Assignment SEMICOLON                              {$$=$1;if(flag_debug)printf("Assigment\n");}
        | ParseArgs SEMICOLON                                   {$$=$1;if(flag_debug)printf("Parseargs\n");}
        | SEMICOLON                                            {$$=NULL;if(flag_debug)printf("semicolon\n");}
        | PRINT LPAR STRLIT RPAR SEMICOLON                        {$$=create_new_node("Print", -1,-1);sprintf(string_temp,"StrLit(\"%s)",$3->value);add_son($$,create_new_node(strdup(string_temp), -1,-1)); if(flag_debug)printf("print String\n");}                   
        | PRINT LPAR BeforeExpr RPAR SEMICOLON                        {$$=create_new_node("Print", -1,-1);add_son($$,$3);if(flag_debug)printf("print resultado\n");}
        | error SEMICOLON                                       {$$=create_new_node("", -1,-1);;if(flag_debug)printf("Recup Erro\n");}
        ;

StatementList: Statement Statement StatementList       {$$=$1;add_new($$,$2);add_new($$,$3);}
             | Statement                               {$$=$1;}
             |                                         {$$=NULL;}
             ;


MethodInvocation: ID LPAR BeforeExpr AuxMI RPAR               {$$=create_new_node("Call", -1,-1);sprintf(string_temp,"Id(%s)",$1->value);add_son($$,create_new_node(strdup(string_temp), $1->linha,$1->coluna));add_new($$->filho,$3);add_new($$->filho,$4); if(flag_debug)printf("funcao varios parâmetros\n");}
                | ID LPAR BeforeExpr RPAR                     {$$=create_new_node("Call", -1,-1);sprintf(string_temp,"Id(%s)",$1->value);add_son($$,create_new_node(strdup(string_temp), $1->linha,$1->coluna));add_new($$->filho,$3);if(flag_debug)printf("funcao 1 parâmetros\n");}
                | ID LPAR RPAR                          {$$=create_new_node("Call", -1,-1);sprintf(string_temp,"Id(%s)",$1->value);add_son($$,create_new_node(strdup(string_temp), $1->linha,$1->coluna));if(flag_debug)printf("funcao 0 parâmetros\n");}
                | ID LPAR error RPAR                    {$$=create_new_node("", -1,-1);if(flag_debug)printf("funcao com invocação inválida\n");}
                ;

AuxMI: COMMA BeforeExpr {$$=$2;}
    | COMMA BeforeExpr AuxMI              {$$=$2;add_new($$,$3); if(flag_debug)printf("Passagemd e parâmetros\n");}
    ;


BeforeExpr: Assignment                  {$$=$1;}
          | Expr                        {$$=$1;}
          ;


Assignment: ID ASSIGN BeforeExpr      {$$=create_new_node("Assign", $2->linha,$2->coluna);sprintf(string_temp,"Id(%s)",$1->value);add_son($$,create_new_node(strdup(string_temp), $1->linha,$1->coluna));add_new($$->filho,$3); if(flag_debug)printf("assigment\n");}

ParseArgs: PARSEINT LPAR ID LSQ BeforeExpr RSQ RPAR   {$$=create_new_node("ParseArgs", $1->linha,$1->coluna);sprintf(string_temp,"Id(%s)",$3->value);add_son($$,create_new_node(strdup(string_temp), $3->linha,$3->coluna));add_new($$->filho,$5);if(flag_debug)printf("Parse Argumentos\n");}
         | PARSEINT LPAR error RPAR                {$$=create_new_node("", $1->linha,$1->coluna);if(flag_debug)printf("Erro no Parse Argumentos\n");}
         ;

Expr: Expr PLUS Expr     {$$=create_new_node("Add", $2->linha,$2->coluna);add_son($$,$1);add_new($$->filho,$3);if(flag_debug)printf("soma\n");}
    | Expr MINUS Expr   {$$=create_new_node("Sub", $2->linha,$2->coluna);add_son($$,$1);add_new($$->filho,$3);;if(flag_debug)printf("subtração\n");}
    | Expr STAR Expr    {$$=create_new_node("Mul", $2->linha,$2->coluna);add_son($$,$1);add_new($$->filho,$3);;if(flag_debug)printf("multiplicação\n");}
    | Expr DIV Expr     {$$=create_new_node("Div", $2->linha,$2->coluna);add_son($$,$1);add_new($$->filho,$3);;if(flag_debug)printf("Divisão\n");}
    | Expr MOD Expr     {$$=create_new_node("Mod", $2->linha,$2->coluna);add_son($$,$1);add_new($$->filho,$3);;if(flag_debug)printf("MOD\n");}
    | Expr AND Expr     {$$=create_new_node("And", $2->linha,$2->coluna);add_son($$,$1);add_new($$->filho,$3);;if(flag_debug)printf("AND\n");}
    | Expr OR Expr      {$$=create_new_node("Or", $2->linha,$2->coluna);add_son($$,$1);add_new($$->filho,$3);;if(flag_debug)printf("OR\n");}
    | Expr XOR Expr    {$$=create_new_node("Xor", $2->linha,$2->coluna);add_son($$,$1);add_new($$->filho,$3);;if(flag_debug)printf("XOR\n");}
    | Expr LSHIFT Expr {$$=create_new_node("Lshift", $2->linha,$2->coluna);add_son($$,$1);add_new($$->filho,$3);;if(flag_debug)printf("LSHIFR\n");}
    | Expr RSHIFT Expr {$$=create_new_node("Rshift", $2->linha,$2->coluna);add_son($$,$1);add_new($$->filho,$3);;if(flag_debug)printf("RSHIFR\n");}
    | Expr EQ Expr {$$=create_new_node("Eq",$2->linha,$2->coluna);add_son($$,$1);add_new($$->filho,$3);;if(flag_debug)printf("Comparação igualdade\n");}
    | Expr GE Expr {$$=create_new_node("Ge", $2->linha,$2->coluna);add_son($$,$1);add_new($$->filho,$3);;if(flag_debug)printf("Comparação maior ou igual\n");}
    | Expr GT Expr {$$=create_new_node("Gt", $2->linha,$2->coluna);add_son($$,$1);add_new($$->filho,$3);;if(flag_debug)printf("Comparação maior\n");}
    | Expr LE Expr {$$=create_new_node("Le",$2->linha,$2->coluna);add_son($$,$1);add_new($$->filho,$3);;if(flag_debug)printf("Comparação menor ou igual\n");}
    | Expr LT Expr {$$=create_new_node("Lt", $2->linha,$2->coluna);add_son($$,$1);add_new($$->filho,$3);;if(flag_debug)printf("Comparação menor\n");}
    | Expr NE Expr {$$=create_new_node("Ne", $2->linha,$2->coluna);add_son($$,$1);add_new($$->filho,$3);;if(flag_debug)printf("Comparação não igual\n");}
    | MINUS Expr %prec NOT {$$=create_new_node("Minus", $2->linha,$2->coluna);add_son($$,$2);if(flag_debug)printf("subtração fim\n");}
    | NOT Expr {$$=create_new_node("Not", $2->linha,$2->coluna);add_son($$,$2);if(flag_debug)printf("negação\n");}
    | PLUS Expr {$$=create_new_node("Plus", $2->linha,$2->coluna);add_son($$,$2);if(flag_debug)printf("soma fim\n");}
    | LPAR BeforeExpr RPAR  {$$=$2;;if(flag_debug)printf("parenteces\n");}
    | MethodInvocation      {$$=$1;;if(flag_debug)printf("chamar função\n");}
    | ParseArgs             {$$=$1;if(flag_debug)printf("ParseArgs\n");}
    | ID                    {sprintf(string_temp,"Id(%s)",$1->value);$$=create_new_node(strdup(string_temp), $1->linha,$1->coluna);if(flag_debug)printf("rever\n");}
    | ID DOTLENGTH          {$$=create_new_node("Length", $2->linha,$2->coluna);sprintf(string_temp,"Id(%s)",$1->value);add_son($$,create_new_node(strdup(string_temp), $1->linha,$1->coluna));if(flag_debug)printf("ID.\n");}
    | INTLIT                {sprintf(string_temp,"DecLit(%s)",$1->value);$$=create_new_node(strdup(string_temp), $1->linha,$1->coluna);if(flag_debug)printf("inteiro\n");}
    | REALLIT               {sprintf(string_temp,"RealLit(%s)",$1->value);$$=create_new_node(strdup(string_temp), $1->linha,$1->coluna);if(flag_debug)printf("num real\n");}
    | BOOLLIT               {sprintf(string_temp,"BoolLit(%s)",$1->value);$$=create_new_node(strdup(string_temp), $1->linha,$1->coluna);if(flag_debug)printf("boleano\n");}
    | LPAR error RPAR {$$=create_new_node("", -1,-1);if(flag_debug)printf("Erro em EXPression\n");}
    ;



%%
// nao sei ao certo o que deve estar nesta parte ainda 


