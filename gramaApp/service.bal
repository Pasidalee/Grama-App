import ballerinax/slack;
import ballerina/http;

configurable string host = ?;
configurable string username = ?;
configurable string password = ?;
configurable string database = ?;
configurable int port = ?;
configurable string slackToken = ?;

@http:ServiceConfig {
    interceptors: [new ResponseErrorInterceptor()]
}
isolated service / on new http:Listener(9090) {

    private final GramaCheckDao gramacheckDao;
    private final slack:Client slackClient;
    private final slack:ConnectionConfig slackConfig = {auth: {token: slackToken}};

    public isolated function init() returns error? {
        // Initialize the database
        self.gramacheckDao = check new (host, username, password, database, port);
        self.slackClient = check new (self.slackConfig);
    }

    isolated resource function get policecheck(string userId) returns boolean|error {
        boolean policeClearance = check self.gramacheckDao.getPoliceStatus(userId);
        return policeClearance;
    }

    isolated resource function get identitycheck(string userId) returns string|error {
        string user = check self.gramacheckDao.getUser(userId);
        return user;
    }

    isolated resource function get addresscheck(string userId, string address) returns string|error {
        string userAddress = check self.gramacheckDao.getUserAddress(userId);
        if userAddress.equalsIgnoreCaseAscii(address.trim()) == false {
            return INVALID_ADDRESS;
        }
        return userAddress;
    }

    isolated resource function post sendMessage(string user_message) returns string|error {
        slack:Message messageParams = {
            channelName: "general",
            text: user_message
        };

        string postResponse = check self.slackClient->postMessage(messageParams);
        check self.slackClient->joinConversation("general");
        return postResponse;

    }

    isolated resource function post storeStatus(string userId, string status) returns error? {
        _ = check self.gramacheckDao.storeStatus(userId, status);
    }

    isolated resource function get getStatus(string userId) returns string|error {
        string status = check self.gramacheckDao.getStatus(userId);
        return status;
    }

}
