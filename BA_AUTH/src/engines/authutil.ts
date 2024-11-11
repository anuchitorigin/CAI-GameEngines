/**
 *  Program:      Authentication Utility for TS
 *  Description:  All functions are included for authentication process
 *  Version:      1.0.2
 *  Updated:      22 Aug 2024
 *  Programmer:   Mr. Anuchit Butkhunthong
 *  E-mail:       anuchit.b@origin55.com
 *  Update Information:
 *    * Version  1.0.2 (22 Aug 2024)
 *      - modify all dateToSQL to use timezoneoffset = true
 *    * Version  1.0.1 (25 Jul 2024)
 *      - Add function verify_user
 *      - Refactor code
 *    * Version  1.0.0 (23 Jan 2024)
 *      - Prepare for V1
 */

//################################# INCLUDE #################################
//---- System Modules ----
import crypto from 'crypto';
import { uid } from 'uid/secure';
import jwt from 'jsonwebtoken';

//---- Application Modules ----
import env from './env';
import dbconnect from './db_auth';
import { xString, xNumber, xDate, addHours, dateToSQL, incident } from './originutil';

//################################# DECLARATION #################################
const THIS_FILENAME = 'authutil.ts';

const create_sessionid = () => crypto.randomUUID();

const create_accesstoken = () => uid(16);

//################################# FUNCTION #################################
async function add_token(user_id: number, callerip: string, callername: string, purpose: string) {
  let token: any;
  let sessionid = create_sessionid();
  let accesstoken = create_accesstoken();
  let expired_at = new Date();
  addHours(env.AUTH_TIMEOUT, expired_at);
  //-- Prepare session record
  let affectedRows = 0;
  try {
    const sql = `
      INSERT INTO log_sessions
        (sessionid, user_id, accesstoken, expired_at, callerip, callername, purpose)
        VALUES
        (?,?,?,?,?,?,?);
    `;
    const result = await dbconnect.execute(sql, [
      sessionid,
      user_id, 
      accesstoken,
      dateToSQL(expired_at, true),
      callerip,
      callername,
      purpose
    ]); // OkPacket { affectedRows: 1, insertId: 5n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
      token = {};
      token.sessionid = sessionid;
      token.accesstoken = accesstoken;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_token', String(err)));
    token = null;
  }
  if (!affectedRows) {
    token = null;
  }
  return token;
}

async function get_id_accesstoken(sessionid: string) {
  let id = 0;
  let user_id = 0;
  let accesstoken = '';
  let expired_at = new Date();
  try {
    const sql = `
      SELECT id, user_id, accesstoken, expired_at FROM log_sessions
        WHERE sessionid = ?
        ORDER BY id DESC
        LIMIT 1;
    `;
    const result = await dbconnect.execute(sql, [
      sessionid
    ]);
    if (result.length > 0) {
      expired_at = xDate(result[0].expired_at);
      if (expired_at.getTime() > Date.now()) {
        id = xNumber(result[0].id);
        user_id = xNumber(result[0].user_id);
        accesstoken = xString(result[0].accesstoken);
      }
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_id_accesstoken', String(err)));
  }
  return {
    id: id,
    user_id: user_id,
    accesstoken: accesstoken
  }
}

async function get_sessionid(user_id: number) {
  let sessionid = '';
  let expired_at = new Date();
  try {
    const sql = `
      SELECT sessionid, expired_at FROM log_sessions
        WHERE user_id = ?
        ORDER BY id DESC
        LIMIT 1;
    `;
    const result = await dbconnect.execute(sql, [
      user_id
    ]);
    if (result.length > 0) {
      sessionid = xString(result[0].sessionid);
      expired_at = xDate(result[0].expired_at);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_sessionid', String(err)));
  }
  if ((!sessionid) || (expired_at.getTime() <= Date.now())) {
    return '';
  }
  return sessionid;
}

async function get_user_by_userid(userid: string) {
  let user = [];
  try {
    const sql = 
      "SELECT id, loginid, roleparam, firstname, lastname, employeeid, remark"+
      "  FROM users"+
      "  WHERE userid = ? AND deleted = 0"+
      "  ORDER BY id DESC"+
      "  LIMIT 1;";
    const result = await dbconnect.execute(sql, [
      userid
    ]);
    if (result.length > 0) {
      user = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_user_by_userid', String(err)));
  }
  return user
}

async function get_profile(userid: string) {
  let user = [];
  try {
    const sql = `
      SELECT u.created_at, u.belocked, u.userid, u.loginid, u.roleparam
        , u.firstname, u.lastname, u.employeeid, u.remark, l.expired_at
        FROM users u
        INNER JOIN log_sessions l ON l.user_id = u.id
        WHERE u.userid = ? AND u.deleted = 0
        ORDER BY u.id DESC
        LIMIT 1;
    `;
    const result = await dbconnect.execute(sql, [
      userid
    ]);
    if (result.length > 0) {
      user = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_profile', String(err)));
  }
  const f_userid = user[0].userid;
  const f_loginid = user[0].loginid;
  if (f_userid == f_loginid) {
    user[0].loginid = '';
  }
  return user;
}

async function update_log_session_user_id(id: number, user_id: number) {
  let affectedRows = 0;
  try {
    const sql = `
      UPDATE log_sessions
        SET user_id = ?
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      user_id,
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':update_log_session_user_id', String(err)));
  }
  return affectedRows;
}

function encode_jwt(payload: any) {
  return jwt.sign(payload, env.JWT_SECRET);
}

function decode_jwt(token: string) {
  let sessionid = '';
  let accesstoken = '';
  try {
    let payload: any = jwt.verify(token, env.JWT_SECRET);
    if (payload.sessionid && payload.accesstoken) {
      sessionid = xString(payload.sessionid);
      accesstoken = xString(payload.accesstoken);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':decode_jwt', String(err)));
  }
  return {
    sessionid: sessionid,
    accesstoken: accesstoken
  }
}

async function verify_auth(sessionid: string, accesstoken: string) {
  const set_blank = () => {
    userid = '';
    user_id = 0;
  }
  let id = 0;
  let userid = '';
  let user_id = 0;
  let expired_at = new Date();
  try {
    const sql = `
      SELECT l.id, l.user_id, l.expired_at, u.userid FROM log_sessions l
        INNER JOIN users u ON u.id = l.user_id
        WHERE l.sessionid = ? AND l.accesstoken = ? AND u.deleted = 0;
    `;
    const result = await dbconnect.execute(sql, [
      sessionid, 
      accesstoken,
    ]);
    if (result.length > 0) {
      id = xNumber(result[0].id);
      userid = xString(result[0].userid);
      user_id = xNumber(result[0].user_id);
      expired_at = xDate(result[0].expired_at);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':verify_auth', String(err)));
  }
  if (id) {
    if (expired_at.getTime() <= Date.now()) { // For multiple sessions
      set_blank();
    }
  } else {
    set_blank();
  }
  return {
    userid: userid,
    user_id: user_id
  }
}

async function verify_jwt(token: string) {
  const { sessionid: sessionid, accesstoken: accesstoken } = decode_jwt(token);
  const { user_id: user_id } = await verify_auth(sessionid, accesstoken);
  return user_id;
}

async function verify_bearer(bearerHeader: string) {
  const bearer = bearerHeader.split(' ');
  const bearerType = bearer[0];
  const bearerToken = bearer[1];
  if ((bearerType != 'Bearer') || (!bearerToken)) {
    return '';
  }
  const { sessionid: sessionid, accesstoken: accesstoken } = decode_jwt(bearerToken);
  const { userid: userid } = await verify_auth(sessionid, accesstoken);
  return userid;
}

async function verify_sender(bearerHeader: string) {
  const bearer = bearerHeader.split(' ');
  const bearerType = bearer[0];
  const bearerToken = bearer[1];
  if ((bearerType != 'Bearer') || (!bearerToken)) {
    return '';
  }
  let sender = '';
  try {
    const sql = `
      SELECT sender FROM auth_tokens
        WHERE apikey = ?
        ORDER BY id DESC
        LIMIT 1;
    `;
    const result = await dbconnect.execute(sql, [
      bearerToken
    ]);
    if (result.length > 0) {
      sender = xString(result[0].sender);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':verify_sender', String(err)));
  }
  return sender;
}

async function verify_user(req: any, res: any, next: any) {
  const bearerHeader = xString(req.headers['authorization']);
  const userid = await verify_bearer(bearerHeader);
  if (!userid) {
    return res.status(401).send('Unauthorized');
  } else {
    res.locals.userid = userid;
    next();
  }
}

export {
  add_token,
  get_id_accesstoken,
  get_sessionid,
  get_user_by_userid,
  get_profile,
  update_log_session_user_id,
  encode_jwt,
  decode_jwt,
  verify_auth,
  verify_jwt,
  verify_bearer,
  verify_sender,
  verify_user,
}