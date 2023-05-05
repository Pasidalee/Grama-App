import ballerina/http;

public type UserNotFoundError record {|
    *http:NotFound;
    ErrorMsg body;
|};

public type InvalidIdentityError record {|
    *http:NotAcceptable;
    ErrorMsg body;
|};

public type ErrorMsg record {|
    string errmsg;
|};
