import ballerina/sql;
import ballerinax/postgresql;

type Address record {|
    string? address_line1;
    string? address_line2;
    string? city;
|};

client class GramaCheckDao {

    postgresql:Client dbClient;
    public function init(string host, string username, string password, string database, int port) returns error? {
        // Initialize the database
        self.dbClient = check new ("silly.db.elephantsql.com", "fomclknn", "fS9aKK3EOMAoj61skMc7Kn2W1pd1SYmA", "fomclknn", 5432);
    }

    function getUser(string userId) returns string|error {
        sql:ParameterizedQuery query = `SELECT user_id FROM user_details WHERE user_id = ${userId}`;
        string user = check self.dbClient->queryRow(query);
        return user;
    }

    function getUserAddress(string userId) returns string|error {
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

    function getPoliceStatus(string userId) returns boolean|error {
        sql:ParameterizedQuery query = `SELECT police_check FROM user_details WHERE user_id = ${userId}`;
        boolean police_check = check self.dbClient->queryRow(query);
        return police_check;
    }
}
