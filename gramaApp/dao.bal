import ballerina/sql;
import ballerinax/mysql;

type Address record {|
    string? address_line1;
    string? address_line2;
    string? city;
|};

type Request record {|
    int request_id;
    string user_id;
    string status;
    boolean user_id_check;
    boolean address_check;
    boolean police_check;
|};

isolated client class GramaCheckDao {

    private final mysql:Client dbClient;
    public isolated function init(string host, string username, string password, string database, int port) returns error? {
        // Initialize the database
        self.dbClient = check new (host, username, password, database, port);
    }

    isolated function storeRequest(string userId) returns error? {
        sql:ParameterizedQuery query = `INSERT INTO certificate_requests (user_id) VALUES (${userId})`;
        _ = check self.dbClient->execute(query);
    }

    isolated function getUser(string userId) returns string|error {
        sql:ParameterizedQuery query = `SELECT user_id FROM user_details WHERE user_id = ${userId}`;
        return self.dbClient->queryRow(query);
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
        return self.dbClient->queryRow(query);
    }

    isolated function updateStatus(string userId, string status) returns error? {
        sql:ParameterizedQuery query = `UPDATE certificate_requests SET status = ${status} WHERE user_id = ${userId} AND 
            status != ${APPROVED} AND status != ${DECLINED}`;
        _ = check self.dbClient->execute(query);
    }

    isolated function getStatus(string userId) returns string|error {
        sql:ParameterizedQuery query = `SELECT status FROM certificate_requests WHERE user_id = ${userId} AND 
            status != ${APPROVED} AND status != ${DECLINED}`;
        return self.dbClient->queryRow(query);
    }

    isolated function updateValidation(string validationType, string userId) returns error? {
        sql:ParameterizedQuery query = ``;
        if validationType == USER_ID_CHECK {
            query = `UPDATE certificate_requests SET user_id_check = true WHERE user_id = ${userId} AND 
            status != ${APPROVED} AND status != ${DECLINED}`;
        } else if validationType == ADDRESS_CHECK {
            query = `UPDATE certificate_requests SET address_check = true WHERE user_id = ${userId} AND 
            status != ${APPROVED} AND status != ${DECLINED}`;
        } else if validationType == POLICE_CHECK {
            query = `UPDATE certificate_requests SET police_check = true WHERE user_id = ${userId} AND status != ${APPROVED} 
            AND status != ${DECLINED}`;
        }
        _ = check self.dbClient->execute(query);
    }

    isolated function getConatctNumber(string userId) returns string|error {
        sql:ParameterizedQuery query = `SELECT contact_number FROM user_details WHERE user_id = ${userId}`;
        return self.dbClient->queryRow(query);
    }

    isolated function getAllUserInfo()  returns stream<Request, sql:Error?>{
        sql:ParameterizedQuery query = `SELECT * FROM user_details`;
        stream<Request, sql:Error?> resultStream = self.dbClient->query(query);
        return resultStream;
    }

}
