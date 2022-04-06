#include "StringUtil.h"
#include <log4pi.h>
#include <sstream>
#include <locale>

using namespace std;
using namespace common::utility;

#ifndef null
#define null 0
#endif

namespace common { namespace utility {

    bool isBlankOrNull(const char *str) {
        
        if (str==nullptr) {
            return true;
        }
        int len=strlen(str);

        if (len==0) {
            return true;
        }

        for (int i=0;i<len;++i) {
            if (!isspace(str[i])) {
                return false;
            }
        }
        return true;
    }   

    string &trim(string &s) {
        ltrim(s);
        rtrim(s);
        return s;
    }

    char *trim(char *s) {
        char *firstNonBlank=s;
        char *p=s;

        while (isspace(*firstNonBlank)) ++firstNonBlank;

        if (firstNonBlank!=s && *firstNonBlank!=0) {
            while (firstNonBlank!=0) {
                p=firstNonBlank;
                ++p;
                ++firstNonBlank;
            }
        }

        int len=strlen(s);

        for (int i=len-1;i>=0;--i) {
            if (!isspace(s[i])) {
                break;
            }
            s[i]=0;
        }
        return s;
    }


    int xstrcmp(const void *a, const void *b) {
        const char *pa = *(const char**)a;
        const char *pb = *(const char**)b;

        return strcmp(pa,pb);
    }

    int strnchr(char *s, char c) {
        char *f=strchr(s,c);
        if (f==NULL) {
            return -1;
        }
        return f-s;
    }


    void ignoreSplitSoftError(int fieldNumber, int expected, int actual) {
    }
    

    int strsplit(vector<char*> &fields, const char *input, const char *fieldSeparator, void (*softError)(int fieldNumber,int expected,int actual))  {
        int fieldSeparatorLen=strlen(fieldSeparator);
        const char *tCurr=input;
        const char *tNext=nullptr;
        const char *tEnd = &input[strlen(input)];

        tNext=strstr(tCurr,fieldSeparator);

        while (tNext) {
            int fieldLen=tNext-tCurr;
            char *field=(char*) malloc(fieldLen+1);

            strncpy(field,tCurr,fieldLen);

            field[fieldLen]=0;
            fields.push_back(field);

            tCurr=tNext+fieldSeparatorLen;      
            tNext=strstr(tCurr,fieldSeparator);
        }

        if (tCurr<tEnd) {
            int fieldLen=tEnd-tCurr;

            if (fieldLen>0) {
                char *field=(char*) malloc(fieldLen+1);

                strncpy(field,tCurr,fieldLen);

                field[fieldLen]=0;
                fields.push_back(field);            
            }
        }
        return fields.size();
    }

    char* chomp(char*s, char c) {
        int len=strlen(s);

        if (s[len-1]==c) {
            s[len-1]=0;
        }
        return s;
    }


    vector<string> split(const string &s, char delim) {
        vector<string> result;
        stringstream ss (s);
        string item;

        while (getline(ss, item, delim)) {
            result.push_back(item);
        }

        return result;
    }

    vector<string> splitWhitespace(const char *input) {
        vector<string> result;

        char *p=(char*)input;
        char *wordStart=p;

        if (input==nullptr) {
            return result;
        }
        while (*p) {
//            fprintf(stderr,"p=%lx c=%c\n",(unsigned long) p,*p);
            if (isspace(*p)) {
                if (p>wordStart) {
                    size_t len = p-wordStart;
//                    fprintf(stderr,"wordstart=%lx len=%lu", (unsigned long)wordStart,len);
                    string part=string{wordStart,len};
                    result.push_back(part);
                }
                while (isspace(*p)) {
                    ++p;
                    continue;
                }
                wordStart=p;
                continue;
            }
            ++p;
        }

        if (p>wordStart) {
            size_t len = p-wordStart;
            result.push_back(string{wordStart,len});
        }

        return result;
    }



    string strvsprintf(const char *format, va_list args) {

        int maxlen= strlen(format)+16384;
        char *tmpstr=(char*)malloc(maxlen);
        memset(tmpstr,0,maxlen);

        const char *overflow="::message exceeds maximum allowed size";

        vsnprintf(tmpstr,maxlen,format,args);
        string rs=string(tmpstr);

        if (strlen(tmpstr)>(maxlen-strlen(overflow)-1)) {
            strcpy(&tmpstr[maxlen-strlen(overflow)-1],overflow);
            tmpstr[maxlen-1]=0;
        }

        free(tmpstr);

        return rs;
    }

    string strprintf(const char *format, ...) {
        va_list args;
        va_start(args, format);

        int maxlen= strlen(format)+16384;
        char *tmpstr=(char*)malloc(maxlen);

        vsnprintf(tmpstr,maxlen,format,args);
        string rs=string(tmpstr);

        free(tmpstr);
        va_end(args);

        return rs;
    }

    int strsplit(const char *input, int expected, const char *fieldSeparator, ...) {
    va_list args;
    va_start(args, fieldSeparator);

    const char *last=input;
    const char *next; 

    int ct=0;
    while (ct<expected && (next=strstr(last, fieldSeparator))!=NULL) {
        char *target=va_arg(args, char *);
        if (target!=NULL) {
            strncpy(target,last,next-last);
            target[next-last]=0;
            ++ct;
        }
        last=next+2;
    }
    if (ct<expected) {
        char *target=va_arg(args, char *);
        if (target!=NULL) {
            strcpy(target,last);
        }
    }
    
    va_end(args);
    return ct+1;
    }

    string& toUpper(string &str) {
        for (auto & c: str) c = toupper(c);
        return str;
    }
    string& toLower(string &str) {
        for (auto & c: str) c = tolower(c);
        return str;
    }


}}