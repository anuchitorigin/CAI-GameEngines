//################################# INCLUDE #################################
//---- System Modules ----
// import crypto from 'crypto';

//---- Application Modules ----
import K from './constant';
import dbconnect from './db_auth';
import { xNumber, incident } from './originutil';

//################################# DECLARATION #################################
const THIS_FILENAME = 'userfunc.ts';

const F_roleparam = {
  SUPER: '"__role-super":1',
}

//################################# FUNCTION #################################
async function get_users() {
  let users = [];
  try {
    const sql = 
      "SELECT userid, loginid, LOCATE(?, roleparam) AS role_super, firstname, lastname"+
      "  FROM users"+
      "  WHERE deleted = 0"+
      "  ORDER BY id;";
    const result = await dbconnect.execute(sql, [
      F_roleparam.SUPER
    ]);
    if (result.length > 0) {
      users = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_users', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return users;
}

async function get_roles() {
  let roles = [];
  try {
    const sql = 
      "SELECT roleid, rolename, roleparam"+
      "  FROM roles"+
      "  ORDER BY id;";
    const result = await dbconnect.execute(sql, []);
    if (result.length > 0) {
      roles = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_roles', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return roles;
}

async function update_user(userid: string, roleparam: string, firstname: string, lastname: string, employeeid: string, remark: string) {
  let affectedRows = 0;
  try {
    const sql = 
      "UPDATE users"+
      "  SET"+
      "    roleparam = ?,"+
      "    firstname = ?,"+
      "    lastname = ?,"+
      "    employeeid = ?,"+
      "    remark = ?"+
      "  WHERE userid = ? AND belocked = 0 AND deleted = 0;";
    const result = await dbconnect.execute(sql, [
      roleparam,
      firstname,
      lastname,
      employeeid,
      remark,
      userid
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':update_user', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function delete_user(userid: string) {
  let affectedRows = 0;
  try {
    const sql = 
      "UPDATE users"+
      "  SET"+
      "    loginid = CONCAT(loginid, ':', userid),"+
      "    deleted = 1"+
      "  WHERE userid = ? AND belocked = 0 AND deleted = 0;";
    const result = await dbconnect.execute(sql, [
      userid
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':delete_user', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

export {
  get_users,
  get_roles,
  update_user,
  delete_user,
}