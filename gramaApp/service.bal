import ballerina/http;

service / on new http:Listener(9090) {

    resource function get policeCheck(string user_id) returns boolean|UserNotFoundError {
        UserEntry? userEntry = userTable[user_id];
    if userEntry is () {
        return {
            body: {
                errmsg: string `User not found`
            }
        };
    }
        return userEntry.police_clearance;
    }
}


public type UserNotFoundError record {|
    *http:NotFound;
    ErrorMsg body;
|};

public type ErrorMsg record {|
    string errmsg;
|};

public type UserEntry record {|
    readonly string user_id;
    string name;
    string addr_line_1;
    string addr_line_2;
    string addr_city;
    boolean police_clearance;
    string status;
|};

public final table<UserEntry> key(user_id) userTable = table [
    {user_id: "123v", name: "John Doe", addr_line_1: "No. 30", addr_line_2: "Palm grove", addr_city: "Colombo", police_clearance: true, status: "Pending"},
    {user_id: "124v", name: "John Doe2", addr_line_1: "No. 30", addr_line_2: "Palm grove", addr_city: "Colombo", police_clearance: true, status: "Pending"},
    {user_id: "125v", name: "John Doe3", addr_line_1: "No. 30", addr_line_2: "Palm grove", addr_city: "Colombo", police_clearance: true, status: "Pending"}
];
