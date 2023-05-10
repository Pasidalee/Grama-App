import ballerinax/slack;
import ballerina/http;

slack:ConnectionConfig slackConfig = {
    auth: {
        token: "AUTH_TOKEN"
    }
};

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

    resource function get addresscheck(string address) returns string|InvalidAddressError {
        UserEntry? userEntry = getUserEntryByAddress(address);

        if userEntry is () {
            return {
                body: {
                    errmsg: string `Address is Invalid`
                }
            };
        }
        return userEntry.user_id;
    }

    resource function post sendMessage(string user_message) returns string|error {
        slack:Client slackClient = check new (slackConfig);

        slack:Message messageParams = {
            channelName: "general",
            text: user_message
        };

        string postResponse = check slackClient->postMessage(messageParams);
        check slackClient->joinConversation("general");
        return postResponse;
    }

}

function getUserEntryByAddress(string address) returns UserEntry? {
    foreach UserEntry user in userTable {
        string user_address = user.addr_line_1 + "," + user.addr_line_2 + "," + user.addr_city;
        if (user_address == address) {
            return user;
        }
    }
    return ();
}
