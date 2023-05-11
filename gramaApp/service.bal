import ballerinax/slack;
import ballerina/http;
import ballerina/io;

configurable string host = ?;
configurable string username = ?;
configurable string password = ?;
configurable string database = ?;
configurable int port = ?;
configurable string slackToken = ?;

slack:ConnectionConfig slackConfig = {
    auth: {
        token: slackToken
    }
};

service / on new http:Listener(9090) {

    GramaCheckDao gramacheckDao;
    public function init() returns error? {
        // Initialize the database
        self.gramacheckDao = check new (host, username, password, database, port);
    }

    resource function get policecheck(string userId) returns boolean|UserNotFoundError {
        boolean|error policeClearance = self.gramacheckDao.getPoliceStatus(userId);
        if policeClearance is error {
            return {
                body: {
                    errmsg: string `User not found`
                }
            };
        }
        return policeClearance;
    }

    resource function get identitycheck(string userId) returns string|InvalidIdentityError {
        string|error user = self.gramacheckDao.getUser(userId);
        if user is error {
            return {
                body: {
                    errmsg: string `Identity is Invalid`
                }
            };
        }
        return user;
    }

    resource function get addresscheck(string userId, string address) returns string|UserNotFoundError|InvalidAddressError {
        string|error userAddress = self.gramacheckDao.getUserAddress(userId);
        if userAddress is error {
            return <UserNotFoundError>{body: {errmsg: string `User not found`}};
        }
        io:println(userAddress);
        io:println(address);
        if userAddress.equalsIgnoreCaseAscii(address) == false {
            return <InvalidAddressError>{body: {errmsg: string `Address is Invalid`}};
        }
        return userAddress;
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
