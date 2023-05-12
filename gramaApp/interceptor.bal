import ballerina/http;

const NO_ROWS_ERROR_MSG = "Query did not retrieve any rows.";
const USER_NOT_FOUND = "User not found";
const INVALID_ADDRESS = "Address is Invalid";

public isolated service class ResponseErrorInterceptor {
    *http:ResponseErrorInterceptor;

    remote isolated function interceptResponseError(error err)
    returns http:InternalServerError|http:NotFound|http:NotAcceptable {
        if err.message().includes(NO_ROWS_ERROR_MSG) {
            return <http:NotFound>{body: {errmsg: USER_NOT_FOUND}};
        }
        if err.message().includes(INVALID_ADDRESS) {
            return <http:NotAcceptable>{body: {errmsg: INVALID_ADDRESS}};
        }
        return <http:InternalServerError>{body: {message: err.message()}};
    }
}