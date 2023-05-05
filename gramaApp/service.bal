import ballerina/http;

service / on new http:Listener(9090) {

    resource function get policecheck(string user_id) returns boolean|UserNotFoundError {
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

    resource function get identitycheck(string user_id) returns string|InvalidIdentityError {
        UserEntry? userEntry = userTable[user_id];
        if userEntry is () {
            return {
                body: {
                    errmsg: string `Identity is Invalid`
                }
            };
        }
        return userEntry.user_id;
    }
    
}
