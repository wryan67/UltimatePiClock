//
// Created by wryan on 2/19/22.
//

#ifndef ES1_HTTPREQUEST_H
#define ES1_HTTPREQUEST_H

#include <vector>
#include <string>

using namespace std;

class HttpRequest {
public:
    vector<pair<string,string>> headers;
    string method;
    string path;
    string version;
    string body;
    string protocol;
    string domain;
    string port;
    string query;

    bool clientDisconnected=false;
    size_t contentLength;
};


#endif //ES1_HTTPREQUEST_H
