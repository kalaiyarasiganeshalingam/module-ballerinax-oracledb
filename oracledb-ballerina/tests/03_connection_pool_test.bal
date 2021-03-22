// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

//import ballerina/lang.runtime as runtime;
//import ballerina/sql;
//import ballerina/lang.'string as stringutils;
//import ballerina/test;
////import ballerina/io;
//
//string poolDB_1 = "POOL_DB_1";
//string poolDB_2 = "POOL_DB_2";
//
//public type Result record {
//   int val;
//};
//
//@test:Config {
//   groups: ["pool"]
//}
//function testGlobalConnectionPoolSingleDestination() {
//   drainGlobalPool(database);
//}
//
//@test:Config {
//   groups: ["pool"]
//}
//function testGlobalConnectionPoolsMultipleDestinations() {
//   drainGlobalPool(poolDB_1);
//   drainGlobalPool(poolDB_2);
//}
//
//@test:Config {
//   groups: ["pool"]
//}
//function testGlobalConnectionPoolSingleDestinationConcurrent() {
//   worker w1 returns [stream<record{}, error>, stream<record{}, error>]|error {
//       return testGlobalConnectionPoolConcurrentHelper1(poolDB_1);
//   }
//
//   worker w2 returns [stream<record{}, error>, stream<record{}, error>]|error {
//       return testGlobalConnectionPoolConcurrentHelper1(poolDB_1);
//   }
//
//   worker w3 returns [stream<record{}, error>, stream<record{}, error>]|error {
//       return testGlobalConnectionPoolConcurrentHelper1(poolDB_1);
//   }
//
//   worker w4 returns [stream<record{}, error>, stream<record{}, error>]|error {
//       return testGlobalConnectionPoolConcurrentHelper1(poolDB_1);
//   }
//
//   record {
//       [stream<record{}, error>, stream<record{}, error>]|error w1;
//       [stream<record{}, error>, stream<record{}, error>]|error w2;
//       [stream<record{}, error>, stream<record{}, error>]|error w3;
//       [stream<record{}, error>, stream<record{}, error>]|error w4;
//   } results = wait {w1, w2, w3, w4};
//
//   var result2 = testGlobalConnectionPoolConcurrentHelper2(poolDB_1);
//
//   (int|error)[][] returnArray = [];
//   // Connections will be released here as we fully consume the data in the following conversion function calls
//   returnArray[0] = check getCombinedReturnValue(results.w1);
//   returnArray[1] = check getCombinedReturnValue(results.w2);
//   returnArray[2] = check getCombinedReturnValue(results.w3);
//   returnArray[3] = check getCombinedReturnValue(results.w4);
//   returnArray[4] = result2;
//
//   // All 5 clients are supposed to use the same pool. Default maximum no of connections is 10.
//   // Since each select operation hold up one connection each, the last select operation should
//   // return an error
//   int i = 0;
//   while(i < 4) {
//       if (returnArray[i][0] is anydata) {
//           test:assertEquals(returnArray[i][0], 1);
//           if (returnArray[i][1] is anydata) {
//              test:assertEquals(returnArray[i][1], 1);
//           } else {
//              test:assertFail("Expected second element of array an integer" + (<error> returnArray[i][1]).message());
//           }
//       } else {
//           test:assertFail("Expected first element of array an integer" + (<error> returnArray[i][0]).message());
//       }
//       i = i + 1;
//   }
//   validateConnectionTimeoutError(result2[2]);
//}
//
//@test:Config {
//   groups: ["pool"]
//}
//function testLocalSharedConnectionPoolConfigSingleDestination() {
//   sql:ConnectionPool pool = {maxOpenConnections: 5};
//   Client oracleDbClient1 = check new (user, password, host, port, poolDB_1, options, pool);
//   Client oracleDbClient2 = check new (user, password, host, port, poolDB_1, options, pool);
//   Client oracleDbClient3 = check new (user, password, host, port, poolDB_1, options, pool);
//   Client oracleDbClient4 = check new (user, password, host, port, poolDB_1, options, pool);
//   Client oracleDbClient5 = check new (user, password, host, port, poolDB_1, options, pool);
//
//   (stream<record{}, error>)[] resultArray = [];
//   resultArray[0] = oracleDbClient1->query("select count(*) as val from Customers where registrationID = 1", Result);
//   resultArray[1] = oracleDbClient2->query("select count(*) as val from Customers where registrationID = 1", Result);
//   resultArray[2] = oracleDbClient3->query("select count(*) as val from Customers where registrationID = 2", Result);
//   resultArray[3] = oracleDbClient4->query("select count(*) as val from Customers where registrationID = 1", Result);
//   resultArray[4] = oracleDbClient5->query("select count(*) as val from Customers where registrationID = 1", Result);
//   resultArray[5] = oracleDbClient5->query("select count(*) as val from Customers where registrationID = 2", Result);
//
//   (int|error)[] returnArray = [];
//   int i = 0;
//   // Connections will be released here as we fully consume the data in the following conversion function calls
//   foreach var x in resultArray {
//       returnArray[i] = getReturnValue(x);
//       i += 1;
//   }
//
//   check oracleDbClient1.close();
//   check oracleDbClient2.close();
//   check oracleDbClient3.close();
//   check oracleDbClient4.close();
//   check oracleDbClient5.close();
//
//   // All 5 clients are supposed to use the same pool created with the configurations given by the
//   // custom pool options. Since each select operation holds up one connection each, the last select
//   // operation should return an error
//   i = 0;
//   while(i < 5) {
//       test:assertEquals(returnArray[i], 1);
//       i = i + 1;
//   }
//   validateConnectionTimeoutError(returnArray[5]);
//}
//
//@test:Config {
//   groups: ["pool"]
//}
//function testLocalSharedConnectionPoolConfigDifferentDbOptions() {
//   sql:ConnectionPool pool = {maxOpenConnections: 3};
//   Client oracleDbClient1 = check new (user, password, host, port, poolDB_1,
//       {connectTimeout: 2, socketTimeout: 10}, pool);
//   Client oracleDbClient2 = check new (user, password, host, port, poolDB_1,
//       {socketTimeoutInSeconds: 10, connectTimeout: 2}, pool);
//   Client oracleDbClient3 = check new (user, password, host, port, poolDB_1,
//       {connectTimeout: 2, socketTimeoutInSeconds: 10}, pool);
//   Client oracleDbClient4 = check new (user, password, host, port, poolDB_1,
//       {connectTimeout: 1}, pool);
//   Client oracleDbClient5 = check new (user, password, host, port, poolDB_1,
//       {connectTimeout: 1}, pool);
//   Client oracleDbClient6 = check new (user, password, host, port, poolDB_1,
//       {connectTimeout: 1}, pool);
//
//   stream<record {} , error>[] resultArray = [];
//   resultArray[0] = oracleDbClient1->query("select count(*) as val from Customers where registrationID = 1", Result);
//   resultArray[1] = oracleDbClient2->query("select count(*) as val from Customers where registrationID = 1", Result);
//   resultArray[2] = oracleDbClient3->query("select count(*) as val from Customers where registrationID = 2", Result);
//   resultArray[3] = oracleDbClient3->query("select count(*) as val from Customers where registrationID = 1", Result);
//
//   resultArray[4] = oracleDbClient4->query("select count(*) as val from Customers where registrationID = 1", Result);
//   resultArray[5] = oracleDbClient5->query("select count(*) as val from Customers where registrationID = 2", Result);
//   resultArray[6] = oracleDbClient6->query("select count(*) as val from Customers where registrationID = 2", Result);
//   resultArray[7] = oracleDbClient6->query("select count(*) as val from Customers where registrationID = 1", Result);
//
//   (int|error)[] returnArray = [];
//   int i = 0;
//   // Connections will be released here as we fully consume the data in the following conversion function calls
//   foreach var x in resultArray {
//       returnArray[i] = getReturnValue(x);
//       i += 1;
//   }
//
//   check oracleDbClient1.close();
//   check oracleDbClient2.close();
//   check oracleDbClient3.close();
//   check oracleDbClient4.close();
//   check oracleDbClient5.close();
//   check oracleDbClient6.close();
//
//   // Since max pool size is 3, the last select function call going through each pool should fail.
//   i = 0;
//   while(i < 3) {
//       test:assertEquals(returnArray[i], 1);
//       test:assertEquals(returnArray[i + 4], 1);
//       i = i + 1;
//   }
//   validateConnectionTimeoutError(returnArray[3]);
//   validateConnectionTimeoutError(returnArray[7]);
//
//}
//
//@test:Config {
//   groups: ["pool"]
//}
//function testLocalSharedConnectionPoolConfigMultipleDestinations() {
//   sql:ConnectionPool pool = {maxOpenConnections: 3};
//   Client oracleDbClient1 = check new (user, password, host, port, poolDB_1, options, pool);
//   Client oracleDbClient2 = check new (user, password, host, port, poolDB_1, options, pool);
//   Client oracleDbClient3 = check new (user, password, host, port, poolDB_1, options, pool);
//   Client oracleDbClient4 = check new (user, password, host, port, poolDB_2, options, pool);
//   Client oracleDbClient5 = check new (user, password, host, port, poolDB_2, options, pool);
//   Client oracleDbClient6 = check new (user, password, host, port, poolDB_2, options, pool);
//
//   stream<record {} , error>[] resultArray = [];
//   resultArray[0] = oracleDbClient1->query("select count(*) as val from Customers where registrationID = 1", Result);
//   resultArray[1] = oracleDbClient2->query("select count(*) as val from Customers where registrationID = 1", Result);
//   resultArray[2] = oracleDbClient3->query("select count(*) as val from Customers where registrationID = 2", Result);
//   resultArray[3] = oracleDbClient3->query("select count(*) as val from Customers where registrationID = 1", Result);
//
//   resultArray[4] = oracleDbClient4->query("select count(*) as val from Customers where registrationID = 1", Result);
//   resultArray[5] = oracleDbClient5->query("select count(*) as val from Customers where registrationID = 2", Result);
//   resultArray[6] = oracleDbClient6->query("select count(*) as val from Customers where registrationID = 2", Result);
//   resultArray[7] = oracleDbClient6->query("select count(*) as val from Customers where registrationID = 1", Result);
//
//   (int|error)[] returnArray = [];
//   int i = 0;
//   // Connections will be released here as we fully consume the data in the following conversion function calls
//   foreach var x in resultArray {
//       returnArray[i] = getReturnValue(x);
//       i += 1;
//   }
//
//   check oracleDbClient1.close();
//   check oracleDbClient2.close();
//   check oracleDbClient3.close();
//   check oracleDbClient4.close();
//   check oracleDbClient5.close();
//   check oracleDbClient6.close();
//
//   // Since max pool size is 3, the last select function call going through each pool should fail.
//   i = 0;
//   while(i < 3) {
//       test:assertEquals(returnArray[i], 1);
//       test:assertEquals(returnArray[i + 4], 1);
//       i = i + 1;
//   }
//   validateConnectionTimeoutError(returnArray[3]);
//   validateConnectionTimeoutError(returnArray[7]);
//}
//
//@test:Config {
//   groups: ["pool"]
//}
//function testLocalSharedConnectionPoolCreateClientAfterShutdown() {
//   sql:ConnectionPool pool = {maxOpenConnections: 2};
//   Client oracleDbClient1 = check new (user, password, host, port, poolDB_1, options, pool);
//   Client oracleDbClient2 = check new (user, password, host, port, poolDB_1, options, pool);
//
//   var dt1 = oracleDbClient1->query("SELECT count(*) as val from Customers where registrationID = 1", Result);
//   var dt2 = oracleDbClient2->query("SELECT count(*) as val from Customers where registrationID = 1", Result);
//   int|error result1 = getReturnValue(dt1);
//   int|error result2 = getReturnValue(dt2);
//
//   // Since both clients are stopped the pool is supposed to shutdown.
//   check oracleDbClient1.close();
//   check oracleDbClient2.close();
//
//   // This call should return an error as pool is shutdown
//   var dt3 = oracleDbClient1->query("SELECT count(*) as val from Customers where registrationID = 1", Result);
//   int|error result3 = getReturnValue(dt3);
//
//   // Now a new pool should be created
//   Client oracleDbClient3 = check new (user, password, host, port, poolDB_1, options, pool);
//
//   // This call should be successful
//   var dt4 = oracleDbClient3->query("SELECT count(*) as val from Customers where registrationID = 1", Result);
//   int|error result4 = getReturnValue(dt4);
//
//   check oracleDbClient3.close();
//
//   test:assertEquals(result1, 1);
//   test:assertEquals(result2, 1);
//   validateApplicationError(result3);
//   test:assertEquals(result4, 1);
//}
//
//@test:Config {
//   groups: ["pool"]
//}
//function testLocalSharedConnectionPoolStopInitInterleave() {
//   sql:ConnectionPool pool = {maxOpenConnections: 2};
//
//   worker w1 returns error? {
//       check testLocalSharedConnectionPoolStopInitInterleaveHelper1(pool, poolDB_1);
//   }
//   worker w2 returns int|error {
//       return testLocalSharedConnectionPoolStopInitInterleaveHelper2(pool, poolDB_1);
//   }
//
//   check wait w1;
//   int|error result = wait w2;
//   test:assertEquals(result, 1);
//}
//
//function testLocalSharedConnectionPoolStopInitInterleaveHelper1(sql:ConnectionPool pool, string database)
//returns error? {
//   Client oracleDbClient = check new (user, password, host, port, database, options, pool);
//   runtime:sleep(10);
//   check oracleDbClient.close();
//}
//
//function testLocalSharedConnectionPoolStopInitInterleaveHelper2(sql:ConnectionPool pool, string database)
//returns @tainted int|error {
//   runtime:sleep(10);
//   Client oracleDbClient = check new (user, password, host, port, database, options, pool);
//   var dt = oracleDbClient->query("SELECT COUNT(*) as val from Customers where registrationID = 1", Result);
//   int|error count = getReturnValue(dt);
//   check oracleDbClient.close();
//   return count;
//}
//
//@test:Config {
//   groups: ["pool"]
//}
//function testShutDownUnsharedLocalConnectionPool() {
//   sql:ConnectionPool pool = {maxOpenConnections: 2};
//   Client oracleDbClient = check new (user, password, host, port, poolDB_1, options, pool);
//
//   var result = oracleDbClient->query("select count(*) as val from Customers where registrationID = 1", Result);
//   int|error retVal1 = getReturnValue(result);
//   // Pool should be shutdown as the only client using it is stopped.
//   check oracleDbClient.close();
//   // This should result in an error return.
//   var resultAfterPoolShutDown = oracleDbClient->query("select count(*) as val from Customers where registrationID = 1",
//       Result);
//   int|error retVal2 = getReturnValue(resultAfterPoolShutDown);
//
//   test:assertEquals(retVal1, 1);
//   validateApplicationError(retVal2);
//}
//
//@test:Config {
//   groups: ["pool"]
//}
//function testShutDownSharedConnectionPool() {
//   sql:ConnectionPool pool = {maxOpenConnections: 1};
//   Client oracleDbClient1 = check new (user, password, host, port, poolDB_1, options, pool);
//   Client oracleDbClient2 = check new (user, password, host, port, poolDB_1, options, pool);
//
//   var result1 = oracleDbClient1->query("select count(*) as val from Customers where registrationID = 1", Result);
//   int|error retVal1 = getReturnValue(result1);
//
//   var result2 = oracleDbClient2->query("select count(*) as val from Customers where registrationID = 2", Result);
//   int|error retVal2 = getReturnValue(result2);
//
//   // Only one client is closed so pool should not shutdown.
//   check oracleDbClient1.close();
//
//   // This should be successful as pool is still up.
//   var result3 = oracleDbClient2->query("select count(*) as val from Customers where registrationID = 2", Result);
//   int|error retVal3 = getReturnValue(result3);
//
//   // This should fail because, even though the pool is up, this client was stopped
//   var result4 = oracleDbClient1->query("select count(*) as val from Customers where registrationID = 2", Result);
//   int|error retVal4 = getReturnValue(result4);
//
//   // Now pool should be shutdown as the only remaining client is stopped.
//   check oracleDbClient2.close();
//
//   // This should fail because this client is stopped.
//   var result5 = oracleDbClient2->query("select count(*) as val from Customers where registrationID = 2", Result);
//   int|error retVal5 = getReturnValue(result4);
//
//   test:assertEquals(retVal1, 1);
//   test:assertEquals(retVal2, 1);
//   test:assertEquals(retVal3, 1);
//   validateApplicationError(retVal4);
//   validateApplicationError(retVal5);
//}
//
//@test:Config {
//   groups: ["pool"]
//}
//function testShutDownPoolCorrespondingToASharedPoolConfig() {
//   sql:ConnectionPool pool = {maxOpenConnections: 1};
//   Client oracleDbClient1 = check new (user, password, host, port, poolDB_1, options, pool);
//   Client oracleDbClient2 = check new (user, password, host, port, poolDB_1, options, pool);
//
//   var result1 = oracleDbClient1->query("select count(*) as val from Customers where registrationID = 1", Result);
//   int|error retVal1 = getReturnValue(result1);
//
//   var result2 = oracleDbClient2->query("select count(*) as val from Customers where registrationID = 2", Result);
//   int|error retVal2 = getReturnValue(result2);
//
//   // This should result in stopping the pool used by this client as it was the only client using that pool.
//   check oracleDbClient1.close();
//
//   // This should be successful as the pool belonging to this client is up.
//   var result3 = oracleDbClient2->query("select count(*) as val from Customers where registrationID = 2", Result);
//   int|error retVal3 = getReturnValue(result3);
//
//   // This should fail because this client was stopped.
//   var result4 = oracleDbClient1->query("select count(*) as val from Customers where registrationID = 2", Result);
//   int|error retVal4 = getReturnValue(result4);
//
//   check oracleDbClient2.close();
//
//   test:assertEquals(retVal1, 1);
//   test:assertEquals(retVal2, 1);
//   test:assertEquals(retVal3, 1);
//   validateApplicationError(retVal4);
//}
//
//@test:Config {
//   groups: ["pool"]
//}
//function testStopClientUsingGlobalPool() {
//   // This client doesn't have pool config specified therefore, global pool will be used.
//   Client oracleDbClient = check new (user, password, host, port, poolDB_1, options);
//
//   var result1 = oracleDbClient->query("select count(*) as val from Customers where registrationID = 1", Result);
//   int|error retVal1 = getReturnValue(result1);
//
//   // This will merely stop this client and will not have any effect on the pool because it is the global pool.
//   check oracleDbClient.close();
//
//   // This should fail because this client was stopped, even though the pool is up.
//   var result2 = oracleDbClient->query("select count(*) as val from Customers where registrationID = 1", Result);
//   int|error retVal2 = getReturnValue(result2);
//
//   test:assertEquals(retVal1, 1);
//   validateApplicationError(retVal2);
//}
//
//@test:Config {
//   groups: ["pool"]
//}
//function testLocalConnectionPoolShutDown() {
//   int|error count1 = getOpenConnectionCount(poolDB_1);
//   int|error count2 = getOpenConnectionCount(poolDB_2);
//   if (count1 is error) {
//       if (count2 is error) {
//           test:assertEquals(count1.message(), count2.message());
//       } else {
//           test:assertFail("Expected invalid count of connection pool" + count2.toString());
//       }
//   } else {
//       test:assertFail("Expected invalid count of connection pool" + count1.toString());
//   }
//}
//
//public type Variable record {
//   string value;
//   string variable_name;
//};
//
//function getOpenConnectionCount(string database) returns @tainted (int|error) {
//   Client oracleDbClient = check new (user, password, host, port, database,options, {maxOpenConnections: 1});
//   var dt = oracleDbClient->query("show status where `variable_name` = 'Threads_connected'", Variable);
//   int|error count = getIntVariableValue(dt);
//   check oracleDbClient.close();
//   return count;
//}
//
//function testGlobalConnectionPoolConcurrentHelper1(string database) returns
//   @tainted [stream<record{}, error>, stream<record{}, error>]|error {
//   Client oracleDbClient = check new (user, password, host, port, database, options);
//   var dt1 = oracleDbClient->query("select count(*) as val from Customers where registrationID = 1", Result);
//   var dt2 = oracleDbClient->query("select count(*) as val from Customers where registrationID = 2", Result);
//   return [dt1, dt2];
//}
//
//function testGlobalConnectionPoolConcurrentHelper2(string database) returns @tainted (int|error)[] {
//   Client oracleDbClient = check new (user, password, host, port,  database, options);
//   (int|error)[] returnArray = [];
//   var dt1 = oracleDbClient->query("select count(*) as val from Customers where registrationID = 1", Result);
//   var dt2 = oracleDbClient->query("select count(*) as val from Customers where registrationID = 2", Result);
//   var dt3 = oracleDbClient->query("select count(*) as val from Customers where registrationID = 1", Result);
//   // Connections will be released here as we fully consume the data in the following conversion function calls
//   returnArray[0] = getReturnValue(dt1);
//   returnArray[1] = getReturnValue(dt2);
//   returnArray[2] = getReturnValue(dt3);
//
//   return returnArray;
//}
//
//function getCombinedReturnValue([stream<record{}, error>, stream<record{}, error>]|error queryResult) returns
//(int|error)[]|error {
//   if (queryResult is error) {
//       return queryResult;
//   } else {
//       stream<record{}, error> x;
//       stream<record{}, error> y;
//       [x, y] = queryResult;
//       (int|error)[] returnArray = [];
//       returnArray[0] = getReturnValue(x);
//       returnArray[1] = getReturnValue(y);
//       return returnArray;
//   }
//}
//
//function getIntVariableValue(stream<record{}, error> queryResult) returns int|error {
//   int count = -1;
//   record {|record {} value;|}? data = check queryResult.next();
//   if (data is record {|record {} value;|}) {
//       record {} variable = data.value;
//       if (variable is Variable) {
//           return 'int:fromString(variable.value);
//       }
//   }
//   check queryResult.close();
//   return count;
//}
//
//
//function drainGlobalPool(string database) {
//   Client oracleDbClient1 = check new (user, password, host, port, database, options);
//   Client oracleDbClient2 = check new (user, password, host, port, database, options);
//   Client oracleDbClient3 = check new (user, password, host, port, database, options);
//   Client oracleDbClient4 = check new (user, password, host, port, database, options);
//   Client oracleDbClient5 = check new (user, password, host, port, database, options);
//
//   stream<record{}, error>[] resultArray = [];
//
//   resultArray[0] = oracleDbClient1->query("select count(*) as val from Customers where registrationID = 1", Result);
//   resultArray[1] = oracleDbClient1->query("select count(*) as val from Customers where registrationID = 2", Result);
//
//   resultArray[2] = oracleDbClient2->query("select count(*) as val from Customers where registrationID = 1", Result);
//   resultArray[3] = oracleDbClient2->query("select count(*) as val from Customers where registrationID = 1", Result);
//
//   resultArray[4] = oracleDbClient3->query("select count(*) as val from Customers where registrationID = 2", Result);
//   resultArray[5] = oracleDbClient3->query("select count(*) as val from Customers where registrationID = 2", Result);
//
//   resultArray[6] = oracleDbClient4->query("select count(*) as val from Customers where registrationID = 1", Result);
//   resultArray[7] = oracleDbClient4->query("select count(*) as val from Customers where registrationID = 1", Result);
//
//   resultArray[8] = oracleDbClient5->query("select count(*) as val from Customers where registrationID = 1", Result);
//   resultArray[9] = oracleDbClient5->query("select count(*) as val from Customers where registrationID = 1", Result);
//
//   resultArray[10] = oracleDbClient5->query("select count(*) as val from Customers where registrationID = 1", Result);
//
//   (int|error)[] returnArray = [];
//   int i = 0;
//   // Connections will be released here as we fully consume the data in the following conversion function calls
//   foreach var x in resultArray {
//       returnArray[i] = getReturnValue(x);
//       i += 1;
//   }
//   // All 5 clients are supposed to use the same pool. Default maximum no of connections is 10.
//   // Since each select operation hold up one connection each, the last select operation should
//   // return an error
//   i = 0;
//   while(i < 10) {
//       test:assertEquals(returnArray[i], 1);
//       i = i + 1;
//   }
//   validateConnectionTimeoutError(returnArray[10]);
//}
//
//function getReturnValue(stream<record{}, error> queryResult) returns int|error {
//   int count = -1;
//   record {|record {} value;|}? data = check queryResult.next();
//   if (data is record {|record {} value;|}) {
//       record {} value = data.value;
//       if (value is Result) {
//           count = value.val;
//       }
//   }
//   check queryResult.close();
//   return count;
//}
//
//function validateApplicationError(int|error dbError) {
//   test:assertTrue(dbError is error);
//   sql:ApplicationError sqlError = <sql:ApplicationError> dbError;
//   test:assertTrue(stringutils:includes(sqlError.message(), "Client is already closed"), sqlError.message());
//}
//
//function validateConnectionTimeoutError(int|error dbError) {
//   test:assertTrue(dbError is error);
//   sql:DatabaseError sqlError = <sql:DatabaseError> dbError;
//   test:assertTrue(stringutils:includes(sqlError.message(), "request timed out after"), sqlError.message());
//}
//
