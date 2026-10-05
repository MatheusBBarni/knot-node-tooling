#ifndef KNOT_DATA_YAML_H
#define KNOT_DATA_YAML_H

#include <ctype.h>
#include <errno.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct { const char *s; size_t n; } KnotYamlSpan;
typedef struct { char *s; size_t n, cap; } KnotYamlBuffer;
typedef struct { char *s; size_t n; } KnotYamlKey;
typedef struct { KnotYamlKey *slots; size_t cap, count; } KnotYamlKeys;
typedef struct {
  KnotYamlSpan *lines; size_t length, line, nodes;
  KnotYamlBuffer out; const char *error;
} KnotYamlParser;

static int knot_y_space(char c) { return c == ' ' || c == '\t' || c == '\r' || c == '\n'; }
static KnotYamlSpan knot_y_trim(KnotYamlSpan v) {
  while (v.n && knot_y_space(*v.s)) { v.s++; v.n--; }
  while (v.n && knot_y_space(v.s[v.n-1])) v.n--;
  return v;
}
static int knot_y_eq(KnotYamlSpan v, const char *s) { size_t n=strlen(s); return n==v.n && !memcmp(v.s,s,n); }
static int knot_y_err(KnotYamlParser *p, const char *status) { p->error=status; return 0; }
static int knot_y_add(KnotYamlParser *p, KnotYamlBuffer *b, const char *s, size_t n) {
  if (n > SIZE_MAX-b->n-1) return knot_y_err(p,"resource_limit");
  if (b->n+n+1 > b->cap) {
    size_t next=b->cap ? b->cap : 64;
    while (next < b->n+n+1) { if (next>SIZE_MAX/2) return knot_y_err(p,"resource_limit"); next*=2; }
    char *grown=realloc(b->s,next); if (!grown) return knot_y_err(p,"resource_limit");
    b->s=grown; b->cap=next;
  }
  if(n)memcpy(b->s+b->n,s,n); b->n+=n; b->s[b->n]=0; return 1;
}
static int knot_y_char(KnotYamlParser *p, KnotYamlBuffer *b, char c) { return knot_y_add(p,b,&c,1); }
static int knot_y_json(KnotYamlParser *p, KnotYamlSpan s) {
  if (!knot_y_char(p,&p->out,'"')) return 0;
  for(size_t i=0;i<s.n;i++) {
    unsigned char c=(unsigned char)s.s[i];
    if (c=='"' || c=='\\') { if (!knot_y_char(p,&p->out,'\\') || !knot_y_char(p,&p->out,(char)c)) return 0; }
    else if (c<32) {
      const char *esc=c=='\n'?"\\n":c=='\r'?"\\r":c=='\t'?"\\t":NULL;
      if (esc) {if (!knot_y_add(p,&p->out,esc,2)) return 0;}
      else {char buf[7]; snprintf(buf,sizeof(buf),"\\u%04x",c); if (!knot_y_add(p,&p->out,buf,6)) return 0;}
    } else if (!knot_y_char(p,&p->out,(char)c)) return 0;
  }
  return knot_y_char(p,&p->out,'"');
}
static int knot_y_hex(char c) { if(c>='0'&&c<='9')return c-'0'; if(c>='a'&&c<='f')return c-'a'+10; if(c>='A'&&c<='F')return c-'A'+10; return -1; }
static int knot_y_unicode(KnotYamlParser *p,KnotYamlBuffer *b,uint32_t cp) {
  if(cp>0x10ffff || (cp>=0xd800&&cp<=0xdfff)) return knot_y_err(p,"syntax_error");
  char bytes[4]; size_t n;
  if(cp<128) {bytes[0]=(char)cp;n=1;}
  else if(cp<2048) {bytes[0]=(char)(0xc0|(cp>>6));bytes[1]=(char)(0x80|(cp&63));n=2;}
  else if(cp<65536) {bytes[0]=(char)(0xe0|(cp>>12));bytes[1]=(char)(0x80|((cp>>6)&63));bytes[2]=(char)(0x80|(cp&63));n=3;}
  else {bytes[0]=(char)(0xf0|(cp>>18));bytes[1]=(char)(0x80|((cp>>12)&63));bytes[2]=(char)(0x80|((cp>>6)&63));bytes[3]=(char)(0x80|(cp&63));n=4;}
  return knot_y_add(p,b,bytes,n);
}
static int knot_y_quote(KnotYamlParser *p,KnotYamlSpan s,size_t *i,KnotYamlBuffer *out) {
  char quote=s.s[(*i)++];
  while(*i<s.n) {
    char c=s.s[(*i)++];
    if(c==quote) {
      if(quote=='\'' && *i<s.n && s.s[*i]=='\'') {(*i)++; if(!knot_y_char(p,out,'\''))return 0;continue;}
      return 1;
    }
    if(c=='\\' && quote=='"') {
      if(*i>=s.n)return knot_y_err(p,"syntax_error");
      c=s.s[(*i)++];
      char escaped=0;
      if(c=='x'||c=='u'||c=='U') {
        size_t digits=c=='x'?2:c=='u'?4:8;uint32_t cp=0;
        if(s.n-*i<digits)return knot_y_err(p,"syntax_error");
        for(size_t j=0;j<digits;j++) {int h=knot_y_hex(s.s[(*i)++]); if(h<0)return knot_y_err(p,"syntax_error");cp=(cp<<4)|(unsigned)h;}
        if(!knot_y_unicode(p,out,cp))return 0;
      } else if(c=='N'||c=='_'||c=='L'||c=='P') {
        uint32_t cp=c=='N'?0x85:c=='_'?0xa0:c=='L'?0x2028:0x2029;
        if(!knot_y_unicode(p,out,cp))return 0;
      } else {
        switch(c) {
          case '0':escaped=0;break;case 'a':escaped=7;break;case 'b':escaped=8;break;
          case 't':escaped=9;break;case 'n':escaped=10;break;case 'v':escaped=11;break;
          case 'f':escaped=12;break;case 'r':escaped=13;break;case 'e':escaped=27;break;
          case ' ':escaped=' ';break;case '\\':escaped='\\';break;case '"':escaped='"';break;
          case '/':escaped='/';break;default:return knot_y_err(p,"syntax_error");
        }
        if(!knot_y_char(p,out,escaped))return 0;
      }
    } else {if(c=='\n'||c=='\r'||((unsigned char)c<32 && c!='\t'))return knot_y_err(p,"syntax_error");if(!knot_y_char(p,out,c))return 0;}
  }
  return knot_y_err(p,"syntax_error");
}
static int knot_y_schema(KnotYamlSpan s) {
  size_t i=0;if(s.n&&(s.s[0]=='+'||s.s[0]=='-'))i++;
  if(s.n-i==4 && s.s[i]=='.' && (s.s[i+1]=='i'||s.s[i+1]=='I') &&
     (s.s[i+2]=='n'||s.s[i+2]=='N') && (s.s[i+3]=='f'||s.s[i+3]=='F'))return 1;
  if(s.n-i==4 && s.s[i]=='.' && (s.s[i+1]=='n'||s.s[i+1]=='N') &&
     (s.s[i+2]=='a'||s.s[i+2]=='A') && (s.s[i+3]=='n'||s.s[i+3]=='N'))return 1;
  if(s.n>=10 && s.s[4]=='-'&&s.s[7]=='-' &&
     isdigit((unsigned char)s.s[0])&&isdigit((unsigned char)s.s[1])&&
     isdigit((unsigned char)s.s[2])&&isdigit((unsigned char)s.s[3])&&
     isdigit((unsigned char)s.s[5])&&isdigit((unsigned char)s.s[6])&&
     isdigit((unsigned char)s.s[8])&&isdigit((unsigned char)s.s[9])&&
     (s.n==10||((s.s[10]=='T'||s.s[10]=='t'||s.s[10]==' ')&&s.n>11&&isdigit((unsigned char)s.s[11]))))return 1;
  return 0;
}
static size_t knot_y_colon(KnotYamlSpan s,int flow);
static int knot_y_plain(KnotYamlParser *p,KnotYamlSpan s) {
  s=knot_y_trim(s);
  if(!s.n)return knot_y_add(p,&p->out,"null",4);
  if(s.s[0]=='&'||s.s[0]=='*'||s.s[0]=='!'||knot_y_eq(s,"<<"))return knot_y_err(p,"data_schema");
  if(knot_y_schema(s))return knot_y_err(p,"data_schema");
  if(knot_y_colon(s,0)!=SIZE_MAX)return knot_y_err(p,"syntax_error");
  if(knot_y_eq(s,"~")||knot_y_eq(s,"null")||knot_y_eq(s,"Null")||knot_y_eq(s,"NULL"))return knot_y_add(p,&p->out,"null",4);
  if(knot_y_eq(s,"true")||knot_y_eq(s,"True")||knot_y_eq(s,"TRUE"))return knot_y_add(p,&p->out,"true",4);
  if(knot_y_eq(s,"false")||knot_y_eq(s,"False")||knot_y_eq(s,"FALSE"))return knot_y_add(p,&p->out,"false",5);
  size_t i=0;if(s.s[i]=='+'||s.s[i]=='-')i++;
  int negative=s.s[0]=='-';
  if(i<s.n && (isdigit((unsigned char)s.s[i]) || (s.s[i]=='.' && i+1<s.n && isdigit((unsigned char)s.s[i+1])))) {
    int base=10;size_t start=i;
    if(i+2<s.n && s.s[i]=='0' && (s.s[i+1]=='x'||s.s[i+1]=='o')) {if(start)return knot_y_err(p,"data_number");base=s.s[i+1]=='x'?16:8;i+=2;}
    if(base!=10 || (i<s.n && s.s[i]!='.')) {
      uint64_t integer=0;size_t digit=i;
      while(i<s.n) {int d=knot_y_hex(s.s[i]);if(d<0||d>=base)break;if(integer>(UINT64_C(9007199254740991)-(unsigned)d)/(unsigned)base)return knot_y_err(p,"data_number");integer=integer*(unsigned)base+(unsigned)d;i++;}
      if(i==s.n && i>digit && (base!=10 || s.s[start]!='0'||i-start==1)) {
        char buf[32];int n=snprintf(buf,sizeof(buf),"%s%llu",negative&&integer?"-":"",(unsigned long long)integer);
        return knot_y_add(p,&p->out,buf,(size_t)n);
      }
      if(base!=10)return knot_y_err(p,"data_number");
    }
    char *tmp=malloc(s.n+1);if(!tmp)return knot_y_err(p,"resource_limit");memcpy(tmp,s.s,s.n);tmp[s.n]=0;
    char *end=NULL;errno=0;double number=strtod(tmp,&end);
    int valid=end==tmp+s.n && isfinite(number) && (floor(number)!=number || fabs(number)<=9007199254740991.0);
    int form=0,decimal=0,exponent=0;
    for(size_t j=start;j<s.n;j++) {char c=s.s[j];if(c=='.')decimal=1;else if(c=='e'||c=='E')exponent=1;}
    form=decimal||exponent;
    if(!form || !valid) {free(tmp);return knot_y_err(p,"data_number");}
    /* JSON requires digits on both sides of a decimal point. Emit a locale-independent decimal spelling. */
    KnotYamlBuffer b={0};size_t k=start;
    if(negative && !knot_y_char(p,&b,'-'))goto number_fail;
    if(tmp[k]=='.' && !knot_y_char(p,&b,'0'))goto number_fail;
    if(tmp[k]=='0' && k+1<s.n && isdigit((unsigned char)tmp[k+1])) {
      while(k+1<s.n && tmp[k]=='0' && isdigit((unsigned char)tmp[k+1]))k++;
    }
    for(;k<s.n;k++) {if(tmp[k]=='.' && (k+1==s.n||tmp[k+1]=='e'||tmp[k+1]=='E')) {if(!knot_y_add(p,&b,".0",2))goto number_fail;}else if(!knot_y_char(p,&b,tmp[k]))goto number_fail;}
    free(tmp);int ok=knot_y_add(p,&p->out,b.s,b.n);free(b.s);return ok;
number_fail:free(tmp);free(b.s);return 0;
  }
  if(s.s[0]=='['||s.s[0]==']'||s.s[0]=='{'||s.s[0]=='}'||s.s[0]==','||s.s[0]==':'||s.s[0]=='?'||s.s[0]=='|'||s.s[0]=='>'||s.s[0]=='%'||s.s[0]=='@'||s.s[0]=='`')return knot_y_err(p,"syntax_error");
  return knot_y_json(p,s);
}
static uint64_t knot_y_hash(const char *s,size_t n) {uint64_t h=UINT64_C(14695981039346656037);for(size_t i=0;i<n;i++)h=(h^(unsigned char)s[i])*UINT64_C(1099511628211);return h;}
static void knot_y_keys_free(KnotYamlKeys *keys) {for(size_t i=0;i<keys->cap;i++)free(keys->slots[i].s);free(keys->slots);}
static int knot_y_key(KnotYamlParser *p,KnotYamlKeys *keys,KnotYamlSpan key) {
  if(keys->count*2>=keys->cap) {
    size_t cap=keys->cap?keys->cap*2:16;if(cap>2097152)return knot_y_err(p,"resource_limit");
    KnotYamlKey *slots=calloc(cap,sizeof(*slots));if(!slots)return knot_y_err(p,"resource_limit");
    for(size_t i=0;i<keys->cap;i++)if(keys->slots[i].s){size_t j=(size_t)knot_y_hash(keys->slots[i].s,keys->slots[i].n)&(cap-1);while(slots[j].s)j=(j+1)&(cap-1);slots[j]=keys->slots[i];}
    free(keys->slots);keys->slots=slots;keys->cap=cap;
  }
  size_t i=(size_t)knot_y_hash(key.s,key.n)&(keys->cap-1);
  while(keys->slots[i].s) {if(keys->slots[i].n==key.n&&!memcmp(keys->slots[i].s,key.s,key.n))return knot_y_err(p,"duplicate_key");i=(i+1)&(keys->cap-1);}
  char *copy=malloc(key.n+1);if(!copy)return knot_y_err(p,"resource_limit");memcpy(copy,key.s,key.n);copy[key.n]=0;keys->slots[i]=(KnotYamlKey){copy,key.n};keys->count++;return 1;
}
static int knot_y_check(KnotYamlParser *p,unsigned depth) {if(depth>128||++p->nodes>1000000)return knot_y_err(p,"resource_limit");return 1;}
static int knot_y_skip(KnotYamlParser *p) {
  while(p->line<p->length) {
    KnotYamlSpan s=p->lines[p->line];size_t i=0;while(i<s.n&&s.s[i]==' ')i++;
    if(i<s.n && s.s[i]=='\t')return knot_y_err(p,"syntax_error");
    if(i==s.n || s.s[i]=='#') {p->line++;continue;}
    if(i==0 && ((s.n>=3&&!memcmp(s.s,"---",3)&&(s.n==3||knot_y_space(s.s[3]))) ||
      (s.n>=3&&!memcmp(s.s,"...",3)&&(s.n==3||knot_y_space(s.s[3]))) || s.s[0]=='%'))return knot_y_err(p,"syntax_error");
    return 1;
  }
  return 1;
}
static size_t knot_y_indent(KnotYamlSpan s) {size_t i=0;while(i<s.n&&s.s[i]==' ')i++;return i;}
static KnotYamlSpan knot_y_clean(KnotYamlSpan s) {
  char quote=0;int level=0;
  for(size_t i=0;i<s.n;i++) {char c=s.s[i];if(quote) {if(quote=='"'&&c=='\\')i++;else if(c==quote){if(quote=='\''&&i+1<s.n&&s.s[i+1]=='\'')i++;else quote=0;}}else if(c=='"'||c=='\'')quote=c;else if(c=='['||c=='{')level++;else if(c==']'||c=='}')level--;else if(c=='#'&&!level&&(!i||knot_y_space(s.s[i-1]))) {s.n=i;break;}}
  while(s.n&&knot_y_space(s.s[s.n-1]))s.n--;return s;
}
static size_t knot_y_colon(KnotYamlSpan s,int flow) {
  char quote=0;int level=0;
  for(size_t i=0;i<s.n;i++){char c=s.s[i];if(quote){if(quote=='"'&&c=='\\')i++;else if(c==quote){if(quote=='\''&&i+1<s.n&&s.s[i+1]=='\'')i++;else quote=0;}continue;}if(c=='"'||c=='\''){quote=c;continue;}if(c=='['||c=='{')level++;else if(c==']'||c=='}')level--;else if(!level&&c==':'&&(i+1==s.n||knot_y_space(s.s[i+1])||(flow&&(s.s[i+1]==','||s.s[i+1]==']'||s.s[i+1]=='}'))))return i;}
  return SIZE_MAX;
}
static int knot_y_parse_key(KnotYamlParser *p,KnotYamlSpan s,KnotYamlBuffer *key) {
  s=knot_y_trim(s);if(!s.n)return knot_y_err(p,"data_schema");
  if(s.s[0]=='&'||s.s[0]=='*'||s.s[0]=='!'||s.s[0]=='?'||s.s[0]=='['||s.s[0]=='{')return knot_y_err(p,"data_schema");
  if(s.s[0]=='"'||s.s[0]=='\''){size_t i=0;if(!knot_y_quote(p,s,&i,key))return 0;if(i!=s.n)return knot_y_err(p,"syntax_error");}
  else {
    if(knot_y_eq(s,"<<")||knot_y_schema(s))return knot_y_err(p,"data_schema");
    if(!knot_y_add(p,key,s.s,s.n))return 0;
  }
  return 1;
}
static void knot_y_flow_ws(KnotYamlSpan s,size_t *i) {
  while(*i<s.n){if(knot_y_space(s.s[*i]))(*i)++;else if(s.s[*i]=='#'&&(!*i||knot_y_space(s.s[*i-1]))){while(*i<s.n&&s.s[*i]!='\n')(*i)++;}else break;}
}
static int knot_y_flow(KnotYamlParser *p,KnotYamlSpan s,size_t *i,unsigned depth) {
  knot_y_flow_ws(s,i);if(!knot_y_check(p,depth))return 0;
  if(*i>=s.n)return knot_y_err(p,"syntax_error");
  char c=s.s[*i];if(c=='['||c=='{') {
    (*i)++;int map=c=='{';KnotYamlKeys keys={0};int ok=knot_y_char(p,&p->out,c);int first=1;
    while(ok) {
      knot_y_flow_ws(s,i);if(*i>=s.n){ok=knot_y_err(p,"syntax_error");break;}
      if(s.s[*i]==(map?'}':']')){(*i)++;ok=knot_y_char(p,&p->out,map?'}':']');break;}
      if(!first && !(ok=knot_y_char(p,&p->out,',')))break;
      first=0;
      if(map) {
        KnotYamlBuffer key={0};knot_y_flow_ws(s,i);size_t start=*i;
        if(*i<s.n&&(s.s[*i]=='"'||s.s[*i]=='\''))ok=knot_y_quote(p,s,i,&key);
        else {while(*i<s.n&&s.s[*i]!=':'&&s.s[*i]!=','&&s.s[*i]!='}'&&s.s[*i]!='\n')(*i)++;ok=knot_y_parse_key(p,(KnotYamlSpan){s.s+start,*i-start},&key);}
        if(ok){knot_y_flow_ws(s,i);if(*i>=s.n||s.s[*i]!=':')ok=knot_y_err(p,"syntax_error");else (*i)++;}
        if(ok)ok=knot_y_key(p,&keys,(KnotYamlSpan){key.s,key.n});
        if(ok)ok=knot_y_json(p,(KnotYamlSpan){key.s,key.n})&&knot_y_char(p,&p->out,':');
        free(key.s);if(!ok)break;
        knot_y_flow_ws(s,i);
        if(*i<s.n&&(s.s[*i]==','||s.s[*i]=='}'))ok=knot_y_check(p,depth+1)&&knot_y_add(p,&p->out,"null",4);
        else ok=knot_y_flow(p,s,i,depth+1);
      }else ok=knot_y_flow(p,s,i,depth+1);
      if(!ok)break;
      knot_y_flow_ws(s,i);if(*i>=s.n){ok=knot_y_err(p,"syntax_error");break;}
      if(s.s[*i]==(map?'}':']'))continue;
      if(s.s[(*i)++]!=','){ok=knot_y_err(p,"syntax_error");break;}
      knot_y_flow_ws(s,i);if(*i<s.n&&s.s[*i]==(map?'}':']')){(*i)++;ok=knot_y_char(p,&p->out,map?'}':']');break;}
    }
    knot_y_keys_free(&keys);return ok;
  }
  if(c=='"'||c=='\'') {KnotYamlBuffer b={0};int ok=knot_y_quote(p,s,i,&b);if(ok)ok=knot_y_json(p,(KnotYamlSpan){b.s,b.n});free(b.s);return ok;}
  size_t start=*i;
  while(*i<s.n&&s.s[*i]!=','&&s.s[*i]!=']'&&s.s[*i]!='}'&&s.s[*i]!='\n') {
    if(s.s[*i]=='#'&&(*i==start||knot_y_space(s.s[*i-1])))break;
    if(s.s[*i]=='['||s.s[*i]=='{')return knot_y_err(p,"syntax_error");
    if(s.s[*i]==':'&&(*i+1==s.n||knot_y_space(s.s[*i+1])||s.s[*i+1]==','||s.s[*i+1]==']'||s.s[*i+1]=='}'))return knot_y_err(p,"syntax_error");
    (*i)++;
  }
  if(*i==start)return knot_y_err(p,"syntax_error");
  return knot_y_plain(p,(KnotYamlSpan){s.s+start,*i-start});
}
static int knot_y_block(KnotYamlParser *p,size_t column,unsigned depth,KnotYamlSpan initial,int has_initial);
static int knot_y_inline(KnotYamlParser *p,KnotYamlSpan raw,size_t parent,unsigned depth,int indentless) {
  if(!knot_y_check(p,depth))return 0;
  KnotYamlSpan s=knot_y_trim(knot_y_clean(raw));
  if(!s.n) {if(!knot_y_skip(p))return 0;if(p->line<p->length){KnotYamlSpan next=p->lines[p->line];size_t n=knot_y_indent(next);
    if(n>parent||(indentless&&n==parent&&n<next.n&&next.s[n]=='-'&&(n+1==next.n||knot_y_space(next.s[n+1])))){
      p->nodes--;return knot_y_block(p,n,depth,(KnotYamlSpan){0},0);}}
    return knot_y_add(p,&p->out,"null",4);}
  if(s.s[0]=='|'||s.s[0]=='>') {
    char style=s.s[0],chomp=0;size_t indicator=0;
    for(size_t i=1;i<s.n;i++){if(s.s[i]=='+'||s.s[i]=='-'){if(chomp)return knot_y_err(p,"syntax_error");chomp=s.s[i];}else if(s.s[i]>='1'&&s.s[i]<='9'){if(indicator)return knot_y_err(p,"syntax_error");indicator=(size_t)(s.s[i]-'0');}else return knot_y_err(p,"syntax_error");}
    size_t base=indicator?parent+indicator:0,end=p->line;
    if(!base)for(size_t j=end;j<p->length;j++){KnotYamlSpan ln=p->lines[j];if(!knot_y_trim(ln).n)continue;size_t n=knot_y_indent(ln);if(n<=parent)break;base=n;break;}
    if(!base)base=parent+1;
    KnotYamlBuffer b={0};int ok=1;size_t trailing=0;int previous_blank=0,previous_more=0;
    for(;end<p->length;end++){
      KnotYamlSpan ln=p->lines[end];int empty=!knot_y_trim(ln).n;size_t n=knot_y_indent(ln);
      if(!empty&&n<base)break;
      if(!empty){ln.s+=base;ln.n-=base;}else ln.n=0;
      int more=ln.n&&ln.s[0]==' ';
      if(trailing){int folded_gap=style=='>'&&trailing>1&&previous_blank&&!empty&&!more;
        if(!folded_gap){char separator=(style=='|'||empty||previous_blank||more||previous_more)?'\n':' ';if(!knot_y_char(p,&b,separator)){ok=0;break;}}}
      if(!knot_y_add(p,&b,ln.s,ln.n)){ok=0;break;}
      previous_blank=empty;previous_more=more;trailing++;
    }
    p->line=end;
    if(ok&&trailing&&chomp!='-')ok=knot_y_char(p,&b,'\n');
    if(ok&&chomp!='+'&&b.n){while(b.n&&b.s[b.n-1]=='\n')b.n--;if(chomp!='-'&&trailing)ok=knot_y_char(p,&b,'\n');}
    if(ok)ok=knot_y_json(p,(KnotYamlSpan){b.s,b.n});free(b.s);return ok;
  }
  if(s.s[0]=='['||s.s[0]=='{') {
    KnotYamlBuffer collected={0};int level=0;char quote=0;int comment=0;size_t end=SIZE_MAX,scan=0;int ok=1;
    while(ok){
      if(!knot_y_add(p,&collected,s.s,s.n)){ok=0;break;}
      for(size_t i=scan;i<collected.n;i++){
        char c=collected.s[i];
        if(comment){if(c=='\n')comment=0;continue;}
        if(quote){if(quote=='"'&&c=='\\'&&i+1<collected.n)i++;
          else if(c==quote){if(quote=='\''&&i+1<collected.n&&collected.s[i+1]=='\'')i++;else quote=0;}}
        else if(c=='#'&&(!i||knot_y_space(collected.s[i-1])))comment=1;
        else if(c=='"'||c=='\'')quote=c;
        else if(c=='['||c=='{')level++;
        else if(c==']'||c=='}'){level--;if(!level){end=i;break;}}
      }
      if(end!=SIZE_MAX)break;
      if(quote||p->line>=p->length){ok=knot_y_err(p,"syntax_error");break;}
      KnotYamlSpan next=p->lines[p->line];size_t spaces=knot_y_indent(next);
      if(spaces<next.n&&next.s[spaces]!='#'&&spaces<=parent){ok=knot_y_err(p,"syntax_error");break;}
      scan=collected.n;s=p->lines[p->line++];if(!knot_y_char(p,&collected,'\n')){ok=0;break;}
    }
    if(ok){KnotYamlSpan rest={collected.s+end+1,collected.n-end-1};
      KnotYamlSpan trimmed=knot_y_trim(rest);
      if(trimmed.n&&(trimmed.s[0]!='#'||rest.s==trimmed.s))ok=knot_y_err(p,"syntax_error");}
    if(ok){size_t i=0;p->nodes--;ok=knot_y_flow(p,(KnotYamlSpan){collected.s,end+1},&i,depth)&&i==end+1;}
    free(collected.s);return ok;
  }
  if(s.s[0]=='"'||s.s[0]=='\''){KnotYamlBuffer b={0};size_t i=0;int ok=knot_y_quote(p,s,&i,&b);if(ok&&i!=s.n)ok=knot_y_err(p,"syntax_error");if(ok)ok=knot_y_json(p,(KnotYamlSpan){b.s,b.n});free(b.s);return ok;}
  return knot_y_plain(p,s);
}
static int knot_y_block(KnotYamlParser *p,size_t column,unsigned depth,KnotYamlSpan initial,int has_initial) {
  if(!has_initial&&(!knot_y_skip(p)||p->line>=p->length))return knot_y_err(p,"syntax_error");
  KnotYamlSpan first=has_initial?initial:(KnotYamlSpan){p->lines[p->line].s+column,p->lines[p->line].n-column};
  if(!has_initial&&knot_y_indent(p->lines[p->line])!=column)return knot_y_err(p,"syntax_error");
  int sequence=first.n&&first.s[0]=='-'&&(first.n==1||knot_y_space(first.s[1]));
  if(sequence){
    if(!knot_y_check(p,depth)||!knot_y_char(p,&p->out,'['))return 0;
    int first_item=1;
    while(p->line<p->length){
      if(!knot_y_skip(p))return 0;
      if(p->line==p->length)break;
      KnotYamlSpan line=p->lines[p->line];if(knot_y_indent(line)!=column||line.n<=column||line.s[column]!='-'||(line.n>column+1&&!knot_y_space(line.s[column+1])))break;
      p->line++;KnotYamlSpan content=knot_y_trim(knot_y_clean((KnotYamlSpan){line.s+column+1,line.n-column-1}));
      if(!first_item&&!knot_y_char(p,&p->out,','))return 0;first_item=0;
      if(content.n&&knot_y_colon(content,0)!=SIZE_MAX){if(!knot_y_block(p,column+2,depth+1,content,1))return 0;}
      else if(!knot_y_inline(p,content,column,depth+1,0))return 0;
    }
    return knot_y_char(p,&p->out,']');
  }
  if(knot_y_colon(knot_y_clean(first),0)!=SIZE_MAX){
    if(!knot_y_check(p,depth)||!knot_y_char(p,&p->out,'{'))return 0;
    KnotYamlKeys keys={0};int first_item=1,ok=1,pending=has_initial;
    while(ok){
      if(!knot_y_skip(p)) {ok=0;break;}
      KnotYamlSpan line;
      if(pending){line=initial;pending=0;}
      else {if(p->line>=p->length||knot_y_indent(p->lines[p->line])!=column)break;line=(KnotYamlSpan){p->lines[p->line].s+column,p->lines[p->line].n-column};p->line++;}
      size_t at=knot_y_colon(knot_y_clean(line),0);if(at==SIZE_MAX){ok=knot_y_err(p,"syntax_error");break;}
      KnotYamlBuffer key={0};ok=knot_y_parse_key(p,(KnotYamlSpan){line.s,at},&key);
      if(ok)ok=knot_y_key(p,&keys,(KnotYamlSpan){key.s,key.n});
      if(ok&&!first_item)ok=knot_y_char(p,&p->out,',');first_item=0;
      if(ok)ok=knot_y_json(p,(KnotYamlSpan){key.s,key.n})&&knot_y_char(p,&p->out,':');
      free(key.s);if(!ok)break;
      ok=knot_y_inline(p,(KnotYamlSpan){line.s+at+1,line.n-at-1},column,depth+1,1);
    }
    knot_y_keys_free(&keys);if(ok)ok=knot_y_char(p,&p->out,'}');return ok;
  }
  if(has_initial)return knot_y_err(p,"syntax_error");
  p->line++;return knot_y_inline(p,first,column,depth,0);
}
static const char *knot_data_yaml_json(const char *source,size_t length,char **json_out) {
  *json_out=NULL;KnotYamlParser p={0};p.error="syntax_error";
  if(!source||length==SIZE_MAX)return "resource_limit";
  size_t count=1;for(size_t i=0;i<length;i++)if(source[i]=='\r'||(source[i]=='\n'&&(!i||source[i-1]!='\r')))count++;
  if(count>1000000||count>SIZE_MAX/sizeof(*p.lines))return "resource_limit";
  p.lines=calloc(count,sizeof(*p.lines));if(!p.lines)return "resource_limit";
  size_t start=0;for(size_t i=0;i<=length;i++)if(i==length||source[i]=='\r'||source[i]=='\n'){
    if(i<length&&source[i]=='\n'&&i&&source[i-1]=='\r')continue;
    p.lines[p.length++]=(KnotYamlSpan){source+start,i-start};
    start=i+1;if(i<length&&source[i]=='\r'&&i+1<length&&source[i+1]=='\n')start++;
  }
  int ok=knot_y_skip(&p)&&p.line<p.length;
  if(ok)ok=knot_y_block(&p,knot_y_indent(p.lines[p.line]),0,(KnotYamlSpan){0},0);
  if(ok)ok=knot_y_skip(&p)&&p.line==p.length;
  free(p.lines);
  if(!ok){free(p.out.s);return p.error;}
  *json_out=p.out.s;return NULL;
}
#endif
