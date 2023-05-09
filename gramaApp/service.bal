import ballerinax/slack;
import ballerina/log;
import ballerina/http;


slack:ConnectionConfig slackConfig = {
    auth: {
        token: "xoxp-5230401240869-5218804671911-5230599377701-62b4900fa7e5f6eb83833b6375f420eb"
    }
};

// webhookUrl:https://hooks.slack.com/services/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

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

     resource function get sendMessage(string user_message) returns string|error{
        log:printInfo("Slack called");
        slack:Client slackClient = check new (slackConfig);

        slack:Message messageParams = {
            channelName: "general",
            text: user_message
        };

        string postResponse = check slackClient->postMessage(messageParams);
        log:printInfo("Message sent" + postResponse);
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
