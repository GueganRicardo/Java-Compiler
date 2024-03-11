%{
	// Ricardo Guegan 2020211358 & Samuel Machado 2020219391
	#include "y.tab.h"
	#include "semantica.h"
	struct no *Program;
	struct tabela *t_global=NULL;
	extern int imprimirtree;
%}

expoente	(e|E)("+"|-)?[0-9](_*[0-9])*
parte		[0-9](_*[0-9])*
id			([a-z]|[A-Z]|[_$])([0-9]|[a-z]|[A-Z]|[_$])*
intlit		0|([1-9](_*[0-9])*)

%{
	int contagem_coluna = 1;
// flag 1 -> -l					analise lex + erros lex
// flag 9 -> -e1 			erros lex
// flag 2 -> -t           		(analise lex + sin) + (erros lex + sin)
// flag 8 -e2 ou omissao     erros lex + sin 
	int flag_prints =  8;
	int line_inicio = 0; 
	int coluna_inicio = 0;
	int flag_returns = 0;

%}

%X COMENTARIOBA COMENTARIOBB STRING ILLSTRING

%%				
"/*"						{BEGIN (COMENTARIOBA); coluna_inicio = contagem_coluna; line_inicio = yylineno; contagem_coluna = contagem_coluna + yyleng;}
<COMENTARIOBA>\*\/				{BEGIN (0);contagem_coluna = contagem_coluna + yyleng;}
<COMENTARIOBA>\n|\r|\r\n				{contagem_coluna = 1; yylineno++;}
<COMENTARIOBA><<EOF>>				{printf("Line %d, col %d: unterminated comment\n", line_inicio, coluna_inicio); coluna_inicio = contagem_coluna; return 0;}
<COMENTARIOBA>.				{contagem_coluna = contagem_coluna + yyleng;}
"//"						{BEGIN (COMENTARIOBB); contagem_coluna = contagem_coluna + yyleng;}
<COMENTARIOBB>\r\n|\r|\n				{BEGIN (0);  contagem_coluna = 1; yylineno++;}
<COMENTARIOBB>.					{contagem_coluna = contagem_coluna + yyleng;}
<COMENTARIOBB><<EOF>>				{coluna_inicio = contagem_coluna; yyterminate();}
\"						{BEGIN (STRING); coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng;}
<STRING>([^\\\n\"\r]|\\(f|n|t|r|\\|\"))*\"			{BEGIN (0);coluna_inicio = contagem_coluna; yylval.info=(struct trio *) malloc(sizeof(struct trio)); yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio; if (flag_prints ==  1) printf("STRLIT(\"%s)\n", yytext);	contagem_coluna = contagem_coluna + yyleng; yylval.info->value=(char*)strdup(yytext); if (flag_returns) return STRLIT;}
<STRING>\\[^fnrt\\\"\n]				{BEGIN (ILLSTRING); printf("Line %d, col %d: invalid escape sequence (%s)\n", yylineno, contagem_coluna, yytext); contagem_coluna = contagem_coluna + yyleng;}
<STRING>\\[fnrt\\\"]							{contagem_coluna = contagem_coluna + yyleng;}
<STRING>\\\n|\\\r|\\\r\n				{BEGIN (0); printf("Line %d, col %d: invalid escape sequence (\\)\n", yylineno, contagem_coluna); printf("Line %d, col %d: unterminated string literal\n", yylineno, coluna_inicio); yylineno++; contagem_coluna = 1;}
<STRING><<EOF>>				{printf("Line %d, col %d: unterminated string literal\n", yylineno, coluna_inicio); yyterminate();}
<STRING>\n|\r|\r\n					{BEGIN (0); printf("Line %d, col %d: unterminated string literal\n", yylineno, coluna_inicio); coluna_inicio = contagem_coluna; yylineno++; contagem_coluna = 1;}
<STRING>.					{contagem_coluna = contagem_coluna + yyleng;}
<ILLSTRING>\"				{BEGIN (0);coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng;}
<ILLSTRING><<EOF>>				{printf("Line %d, col %d: unterminated string literal\n", yylineno, coluna_inicio); yyterminate();}
<ILLSTRING>\n|\r|\r\n				{BEGIN (0); printf("Line %d, col %d: unterminated string literal\n", yylineno, coluna_inicio); coluna_inicio = contagem_coluna; yylineno++; contagem_coluna = 1;}
<ILLSTRING>\\[^fnrt\\\"]			{printf("Line %d, col %d: invalid escape sequence (%s)\n", yylineno, contagem_coluna, yytext); contagem_coluna = contagem_coluna + yyleng;}
<ILLSTRING>\\[fnrt\\\"]							{contagem_coluna = contagem_coluna + yyleng;}
<ILLSTRING>\\\n|\\\r|\\\r\n					{BEGIN (0); printf("Line %d, col %d: invalid escape sequence (\\)\n", yylineno, contagem_coluna); printf("Line %d, col %d: unterminated string literal\n", yylineno, coluna_inicio); coluna_inicio = contagem_coluna; yylineno++; contagem_coluna = 1;}
<ILLSTRING>.					{contagem_coluna = contagem_coluna + yyleng;}
&&						{if (flag_prints ==  1) printf("AND\n");coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return AND;}
((true)|(false))		{if (flag_prints ==  1) printf("BOOLLIT(%s)\n", yytext);yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio;contagem_coluna = contagem_coluna + yyleng; yylval.info->value=(char*)strdup(yytext); if (flag_returns) return BOOLLIT;}
"*"						{if (flag_prints ==  1) printf("STAR\n");yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio;coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return STAR;}
==						{if (flag_prints ==  1) printf("EQ\n"); yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio;coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return EQ;}
,						{if (flag_prints ==  1) printf("COMMA\n");coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return COMMA;}
"/"						{if (flag_prints ==  1) printf("DIV\n");yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio;coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return DIV;}
=						{if (flag_prints ==  1) printf("ASSIGN\n");yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio;coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return ASSIGN;}
>=						{if (flag_prints ==  1) printf("GE\n"); yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio;coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return GE;}
>						{if (flag_prints ==  1) printf("GT\n");yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio;coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return GT;}
"{"						{if (flag_prints ==  1) printf("LBRACE\n"); coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return LBRACE;} 
"<"=						{if (flag_prints ==  1) printf("LE\n");coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return LE;}
"("						{if (flag_prints ==  1) printf("LPAR\n"); coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return LPAR;}
"["						{if (flag_prints ==  1) printf("LSQ\n"); coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return LSQ;}
"<"						{if (flag_prints ==  1) printf("LT\n"); yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio;coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return LT;}
-						{if (flag_prints ==  1) printf("MINUS\n");yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio;coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return MINUS;}
"%"						{if (flag_prints ==  1) printf("MOD\n"); yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio;coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return MOD;}
!=						{if (flag_prints ==  1) printf("NE\n"); yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio;coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return NE;}
!						{if (flag_prints ==  1) printf("NOT\n"); yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio;coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return NOT;}
"||"						{if (flag_prints ==  1) printf("OR\n"); yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio;coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return OR;}
"+"						{if (flag_prints ==  1) printf("PLUS\n"); yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio; coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return PLUS;}
"}"						{if (flag_prints ==  1) printf("RBRACE\n"); coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return RBRACE;}
")"						{if (flag_prints ==  1) printf("RPAR\n"); coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return RPAR;}
"]"						{if (flag_prints ==  1) printf("RSQ\n"); coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return RSQ;}
;						{if (flag_prints ==  1) printf("SEMICOLON\n");coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return SEMICOLON;}
->						{if (flag_prints ==  1) printf("ARROW\n"); yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio;coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return ARROW;}
"<<"						{if (flag_prints ==  1) printf("LSHIFT\n");yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio;coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return LSHIFT;}
>>						{if (flag_prints ==  1) printf("RSHIFT\n");yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio;coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return RSHIFT;}
"^"						{if (flag_prints ==  1) printf("XOR\n"); yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio;coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return XOR;}
boolean						{if (flag_prints ==  1) printf("BOOL\n"); coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return BOOL;}
class						{if (flag_prints ==  1) printf("CLASS\n"); coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return CLASS;}
"."length					{if (flag_prints ==  1) printf("DOTLENGTH\n"); yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio;coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return DOTLENGTH;}
double						{if (flag_prints ==  1) printf("DOUBLE\n");coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return DOUBLE;}
else						{if (flag_prints ==  1) printf("ELSE\n"); coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return ELSE;}
if						{if (flag_prints ==  1) printf("IF\n");coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return IF;}
int						{if (flag_prints ==  1) printf("INT\n");coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return INT;}
System"."out"."print				{if (flag_prints ==  1) printf("PRINT\n");coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return PRINT;}
Integer"."parseInt				{if (flag_prints ==  1) printf("PARSEINT\n");yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio;coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return PARSEINT;}
public						{if (flag_prints ==  1) printf("PUBLIC\n");coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return PUBLIC;}
return						{if (flag_prints ==  1) printf("RETURN\n");coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return RETURN;}
static						{if (flag_prints ==  1) printf("STATIC\n");coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return STATIC;}
String						{if (flag_prints ==  1) printf("STRING\n");coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return STR;}
void						{if (flag_prints ==  1) printf("VOID\n"); coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return VOID;}
while						{if (flag_prints ==  1) printf("WHILE\n"); coluna_inicio = contagem_coluna;contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return WHILE;}
null|Integer|System|--|"++"|abstract|assert|break|byte|case|catch|char|const|default|do|enum|extends|final|finally|float|for|goto|implements|import|instanceof|interface|long|native|new|package|private|protected|short|strictfp|super|switch|synchronized|this|throw|throws|transient|try|volatile|continue|implements|import|instanceof|interface|long|native|new|final|finally|float|for|goto|throws		{if (flag_prints ==  1) printf("RESERVED(%s)\n", yytext); coluna_inicio = contagem_coluna; contagem_coluna = contagem_coluna + yyleng; if (flag_returns) return RESERVED;}
{id}						{if (flag_prints ==  1) printf("ID(%s)\n", yytext);yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio; contagem_coluna = contagem_coluna + yyleng; yylval.info->value=(char*)strdup(yytext); if (flag_returns) return ID;}
({parte}{expoente})|("."{parte}{expoente}?)|({parte}"."{parte}?{expoente}?)					{if (flag_prints ==  1) printf("REALLIT(%s)\n", yytext);yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio; contagem_coluna = contagem_coluna + yyleng; yylval.info->value=(char*)strdup(yytext); if (flag_returns) return REALLIT;}
{intlit}					{if (flag_prints ==  1) printf("INTLIT(%s)\n", yytext);yylval.info=(struct trio *) malloc(sizeof(struct trio));coluna_inicio = contagem_coluna; yylval.info->linha = yylineno; yylval.info->coluna = coluna_inicio; contagem_coluna = contagem_coluna + yyleng; yylval.info->value=(char*)strdup(yytext); if (flag_returns) return INTLIT;}
" "|\t|\f|\"				{contagem_coluna = contagem_coluna + yyleng;}
\n|\r|\r\n						{contagem_coluna=1;yylineno++;}
.						{printf("Line %d, col %d: illegal character (%s)\n", yylineno, contagem_coluna, yytext); contagem_coluna = contagem_coluna + yyleng;}
<<EOF>>					{coluna_inicio = contagem_coluna; return 0;}
%%
#include <string.h>


void yyerror ( char *s) {
    imprimirtree =0;
    if ((int)yytext[strlen(yytext)-1] == 34) printf("Line %d, col %d: %s: \"%s\n", yylineno, coluna_inicio-1, s, yytext);
    else printf("Line %d, col %d: %s: %s\n", yylineno, coluna_inicio, s, yytext);
}



int yywrap()
{
return 1;
}



int main(int argc, char* argv[])
{
	if (argc > 1) {
		if (strcmp(argv[1],"-l") == 0) {
			flag_prints =  1;
			yylex();
		}
		else if (strcmp(argv[1], "-e1") == 0) {
			flag_prints =  0;
			yylex();
		}
		else if(strcmp(argv[1],"-t") == 0){
			flag_returns = 1;
			flag_prints =  0;
			yyparse();
			if(imprimirtree){
				print_arvore(Program, 0);
				esvazia_arvore(Program);
			}
		}
		else if(strcmp(argv[1],"-e2") == 0) {
			flag_returns = 1;
			yyparse();
		}
		else if(strcmp(argv[1],"-s") == 0) {
			flag_returns = 1;
			yyparse();
			controi_tabela_global(Program);
			controi_tabela(Program);
			imprime_tabela(t_global);
			print_arvore(Program, 0);
			esvazia_arvore(Program);
		}

	}
	else { // neste caso comporta-se como -e2
		flag_prints =  0;
		flag_returns = 1;
		yyparse();
	}
	return 0;

}


