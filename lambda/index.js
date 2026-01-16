// File: index.jx

const AWS = require("aws-sdk");
const db = new AWS.DynamoDB.DocumentClient();
const USERS_TABLE = process.env.USERS_TABLE;
const COUNTERS_TABLE = process.env.COUNTERS_TABLE;

function jsonResponse(statusCode, body) {
  return {
    statusCode,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*"
    },
    body: JSON.stringify(body)
  };
}

exports.handler = async (event) => {
  try {
    const method = event.requestContext.http.method;
    const path = event.requestContext.http.path || "/";

    if (method === "POST" && path === "/register") {
      const body = event.body ? JSON.parse(event.body) : {};
      const required = ["firstName","lastName","email","password","studentId","accountType","country","phone"];
      for (const r of required) {
        if (!body[r] || body[r].toString().trim() === "") {
          return jsonResponse(400, { message: `Missing field: ${r}` });
        }
      }

      // create simple userId
      const userId = Date.now().toString() + Math.floor(Math.random()*10000).toString();

      const item = {
        userId,
        firstName: body.firstName,
        lastName: body.lastName,
        email: body.email,
        studentId: body.studentId,
        accountType: body.accountType,
        country: body.country,
        phone: body.phone,
        createdAt: new Date().toISOString()
        // password omitted intentionally from stored demo (but in real usage you would hash and store)
      };

      await db.put({
        TableName: USERS_TABLE,
        Item: item
      }).promise();

      return jsonResponse(200, { message: "Registration successful", userId });
    }

    if (method === "GET" && path === "/counter") {
      const res = await db.update({
        TableName: COUNTERS_TABLE,
        Key: { id: "visits" },  // <-- corrected from pk to id
        UpdateExpression: "SET #c = if_not_exists(#c, :zero) + :inc",
        ExpressionAttributeNames: { "#c": "count" },
        ExpressionAttributeValues: { ":inc": 1, ":zero": 0 },
        ReturnValues: "UPDATED_NEW"
      }).promise();

      const count = res.Attributes.count || 0;
      return jsonResponse(200, { count });
    }

    return jsonResponse(200, { message: "IUSB backend running. Use POST /register or GET /counter" });

  } catch (err) {
    console.error("handler error", err);
    return jsonResponse(500, { message: "Internal Server Error", error: err.message });
  }
};



// IU-International University of Applied Sciences
// Course Code: DLBSEPCP01_E
// Author: Gabriel Manu
// Matriculation ID: 9212512