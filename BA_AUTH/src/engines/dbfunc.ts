//################################# INCLUDE #################################
//---- System Modules ----
import crypto from 'crypto';

//---- Application Modules ----
import K from './constant';
import dbconnect from './db_auth';
import { xNumber, dateToSQL, incident } from './originutil';

//################################# DECLARATION #################################
const THIS_FILENAME = 'dbfunc.ts';

//################################# FUNCTION #################################
async function add_user(loginid: string, passcode: string, roleid: string, firstname: string, lastname: string) {
  const userid = crypto.randomUUID();
  let roleparam = '{}';
  let role = await get_role(roleid);
  if (role == K.SYS_INTERNAL_PROCESS_ERROR) {
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  if (role.roleparam) {
    roleparam = role.roleparam;
  }
  let id = 0;
  try {
    const sql = `
      INSERT INTO users
        (userid, loginid, passcode, roleparam, firstname, lastname)
        VALUES
        (?,?,?,?,?,?)
        RETURNING id;
    `;
    const result = await dbconnect.execute(sql, [
      userid,
      loginid,
      passcode,
      roleparam,
      firstname,
      lastname
    ]);
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':add_user', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return id;
}

async function get_role(roleid: string) {
  let role = null;
  try {
    const sql = `
      SELECT rolename, roleparam
        FROM roles
        WHERE roleid = ?
        ORDER BY id DESC
        LIMIT 1;
    `;
    const result = await dbconnect.execute(sql, [
      roleid
    ]);
    if (result.length > 0) {
      role = result[0];
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_role', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return role;
}

async function get_user(id: number) {
  let user = null;
  try {
    const sql = `
      SELECT userid, loginid, firstname, lastname
        FROM users
        WHERE id = ? AND deleted = 0;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]);
    if (result.length > 0) {
      user = result[0];
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_user', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return user;
}

async function get_user_id_from_signup(loginid: string) {
  // Prepare SQL
  let whereclause = "  WHERE deleted = 0";
  let searchstr = '';
  whereclause += "  AND loginid = ?";
  searchstr = loginid;
  // Execute SQL
  let id = 0;
  try {
    const sql = `
      SELECT id FROM users
        ${whereclause}
        ORDER BY id DESC
        LIMIT 1;
    `;
    const result = await dbconnect.execute(sql, [
      searchstr
    ]);
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_user_id_from_signup', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return id;
}

async function get_user_id_credential(loginid: string, passcode: string) {
  let id = 0;
  try {
    const sql = `
      SELECT id FROM users
        WHERE loginid = ? AND passcode = ? AND deleted = 0
        ORDER BY id DESC
        LIMIT 1;
    `;
    const result = await dbconnect.execute(sql, [
      loginid, 
      passcode,
    ]);
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_user_id_credential', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return id;
}

async function reset_passcode(id: number, passcode: string) {
  let affectedRows = 0;
  // Force all sessions expired
  const datenow = new Date();
  const datezero = new Date(0);
  try {
    const sql = `
      UPDATE log_sessions
        SET expired_at = ?
        WHERE expired_at > ? 
          AND user_id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      dateToSQL(datezero, true),
      dateToSQL(datenow, true),
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':reset_passcode:1', String(err)));
    return 0;
  }
  // Reset passcode
  try {
    const sql = `
      UPDATE users
        SET passcode = ?
        WHERE id = ? AND deleted = 0;
    `;
    const result = await dbconnect.execute(sql, [
      passcode,
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':reset_passcode:2', String(err)));
  }
  return affectedRows;
}

async function change_passcode(id: number, oldpass: string, newpass: string, sessionid: string) {
  // Force all sessions expired except current session
  const datenow = new Date();
  const datezero = new Date(0);
  try {
    const sql = `
      UPDATE log_sessions
        SET expired_at = ?
        WHERE expired_at > ? AND user_id = ? AND sessionid <> ?;
    `;
    await dbconnect.execute(sql, [
      dateToSQL(datezero, true),
      dateToSQL(datenow, true),
      id,
      sessionid
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':change_passcode:1', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  // Update new passcode
  let affectedRows = 0;
  try {
    const sql = `
      UPDATE users
        SET passcode = ?
        WHERE id = ? AND passcode = ? AND deleted = 0;
    `;
    const result = await dbconnect.execute(sql, [
      newpass,
      id,
      oldpass
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':change_passcode:2', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

export {
  add_user,
  get_role,
  get_user,
  get_user_id_from_signup,
  get_user_id_credential,
  reset_passcode,
  change_passcode,
}