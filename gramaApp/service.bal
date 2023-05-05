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
