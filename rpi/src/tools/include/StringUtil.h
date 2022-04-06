#pragma once

#ifndef _StringUtil_
#define _StringUtil_ true

#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>

#include <string>
#include <vector>
#include <algorithm> 
#include <cctype>
#include <locale>

using namespace std;

#define string2upper(str)  for (auto & c: str) c = toupper(c);
#define string2lower(str)  for (auto & c: str) c = tolower(c);
#define str2lower(str)     for (int i=0; i<strlen(str); ++i) str[i]=tolower(str[i]);
#define str2upper(str)     for (int i=0; i<strlen(str); ++i) str[i]=toupper(str[i]);

namespace common { namespace utility {

    char *chomp(char *s, char c);

    // trim from start (in place)
    static inline void ltrim(std::string &s) {
        s.erase(s.begin(), std::find_if(s.begin(), s.end(), [](unsigned char ch) {
            return !std::isspace(ch);
        }));
    }

    // trim from end (in place)
    static inline void rtrim(std::string &s) {
        s.erase(std::find_if(s.rbegin(), s.rend(), [](unsigned char ch) {
            return !std::isspace(ch);
        }).base(), s.end());
    }

    char *trim(char *s);

    string &trim(string &s);


    bool isBlankOrNull(const char *);

    string &toUpper(string &x);

    string &toLower(string &x);


    int xstrcmp(const void *a, const void *b);

    int strnchr(char *s, char c);

    int strsplit(vector<char *> &fields, const char *input, const char *fieldSeparator,
                 void (*softError)(int fieldNumber, int expected, int actual));

    void ignoreSplitSoftError(int fieldNumber, int expected, int actual);

    int strsplit(const char *input, int expected, const char *fieldSeparator, ...);

    string strprintf(const char *format, ...);

    string strvsprintf(const char *format, va_list args);

    vector<string> split(const string &s, char delim);

    vector<string> splitWhitespace(const char *s);

}}

#endif // _StringUtil_