import ballerina/sql;
import ballerinax/postgresql;

type Address record {|
    string? address_line1;
    string? address_line2;
    string? city;
|};

isolated client class GramaCheckDao {

    private final postgresql:Client dbClient;
    public isolated function init(string host, string username, string password, string database, int port) returns error? {
        // Initialize the database
        self.dbClient = check new (host, username, password, database, port);
    }

    isolated function getUser(string userId) returns string|error {
        sql:ParameterizedQuery query = `SELECT user_id FROM user_details WHERE user_id = ${userId}`;
        string user = check self.dbClient->queryRow(query);
        return user;
    }

    isolated function getUserAddress(string userId) returns string|error {
        sql:ParameterizedQuery query = `SELECT address_line1, address_line2, city FROM user_details WHERE user_id = ${userId}`;
        Address address = check self.dbClient->queryRow(query);
        string completeAddress = "";
        string? addressLine1 = address?.address_line1;
        string? addressLine2 = address?.address_line2;
        string? city = address?.city;
        if addressLine1 != () {
            completeAddress = addressLine1;
        }
        if addressLine2 != () {
            completeAddress += ", " + addressLine2;
        }
        if city != () {
            completeAddress += ", " + city;
        }
        return completeAddress;
    }

    isolated function getPoliceStatus(string userId) returns boolean|error {
        sql:ParameterizedQuery query = `SELECT police_check FROM user_details WHERE user_id = ${userId}`;
        boolean police_check = check self.dbClient->queryRow(query);
        return police_check;
    }

    isolated function storeStatus(string userId, string status) returns error? {
        sql:ParameterizedQuery query = `UPDATE user_details SET status = ${status} WHERE user_id = ${userId}`;
        _ = check self.dbClient->execute(query);
    } 

    isolated function getStatus(string userId) returns string|error {
        sql:ParameterizedQuery query = `SELECT status FROM user_details WHERE user_id = ${userId}`;
        string status = check self.dbClient->queryRow(query);
        return status;
    }
}
