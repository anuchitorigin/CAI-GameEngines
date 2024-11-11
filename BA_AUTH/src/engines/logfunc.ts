//################################# INCLUDE #################################
//---- System Modules ----
// import crypto from 'crypto';

//---- Application Modules ----
import K from './constant';
import dbconnect from './db_log';
import { xString, xNumber, incident } from './originutil';

//################################# DECLARATION #################################
const THIS_FILENAME = 'logfunc.ts';

//################################# FUNCTION #################################
async function add_log_sys(sysid: string, f_incident: string, logdetail: string) {
  let id = 0;
  try {
    const sql = `
      INSERT INTO log_syss
        (sysid, incident, logdetail)
        VALUES
        (?,?,?)
        RETURNING id;
    `;
    const result = await dbconnect.execute(sql, [
      sysid,
      f_incident,
      logdetail
    ]);
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':add_log_sys', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return id;
}

async function add_log_user(userid: string, f_incident: string, logdetail: string) {
  let id = 0;
  try {
    const sql = `
      INSERT INTO log_users
        (userid, incident, logdetail)
        VALUES
        (?,?,?)
        RETURNING id;
    `;
    const result = await dbconnect.execute(sql, [
      userid,
      f_incident,
      logdetail
    ]);
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':add_log_user', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return id;
}

async function get_log_syss(
  datefrom: string,
  dateto: string,
  sysid: string, 
  f_incident: string, 
  logdetail: string,
  filter: any
) {
  const limit = xNumber(filter.limit);
  const page = xNumber(filter.page);
  const sort = xString(filter.sort);
  // Validation
  if ((limit <= 0) || (page <= 0)) {
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  let p = page - 1;
  if (p <= 0) { p = 0; }
  const offset = p * limit;
  let sortclause = "ASC";
  if (sort.toLowerCase() == 'desc') {
    sortclause = "DESC";
  }
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (datefrom) {
    whereclause += " AND created_at >= ?";
    argumentarr.push(datefrom);
  }
  if (dateto) {
    whereclause += " AND created_at < ?";
    argumentarr.push(dateto);
  }
  if (sysid) {
    whereclause += " AND sysid = ?";
    argumentarr.push(sysid.trim());
  }
  if (f_incident) {
    whereclause += " AND incident LIKE ?";
    argumentarr.push('%'+f_incident.trim()+'%');
  }
  if (logdetail) {
    whereclause += " AND logdetail LIKE ?";
    argumentarr.push('%'+logdetail.trim()+'%');
  }
  const limitclause = " LIMIT "+offset+","+limit;
  // Execute SQL
  let log_users:any = [];
  try {
    const sql = `
      SELECT id, created_at, sysid, incident, logdetail
        FROM log_syss
        ${whereclause}
        ORDER BY id ${sortclause}
        ${limitclause};
    `;
    const result:any = await dbconnect.execute(sql, argumentarr);
    if (Array.isArray(result) && (result.length > 0)) {
      log_users = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_log_syss', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return log_users;
}

async function get_log_users(
  datefrom: string,
  dateto: string,
  userid: string, 
  f_incident: string, 
  logdetail: string,
  filter: any
) {
  const limit = xNumber(filter.limit);
  const page = xNumber(filter.page);
  const sort = xString(filter.sort);
  // Validation
  if ((limit <= 0) || (page <= 0)) {
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  let p = page - 1;
  if (p <= 0) { p = 0; }
  const offset = p * limit;
  let sortclause = "ASC";
  if (sort.toLowerCase() == 'desc') {
    sortclause = "DESC";
  }
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (datefrom) {
    whereclause += " AND created_at >= ?";
    argumentarr.push(datefrom);
  }
  if (dateto) {
    whereclause += " AND created_at < ?";
    argumentarr.push(dateto);
  }
  if (userid) {
    whereclause += " AND userid = ?";
    argumentarr.push(userid.trim());
  }
  if (f_incident) {
    whereclause += " AND incident LIKE ?";
    argumentarr.push('%'+f_incident.trim()+'%');
  }
  if (logdetail) {
    whereclause += " AND logdetail LIKE ?";
    argumentarr.push('%'+logdetail.trim()+'%');
  }
  const limitclause = " LIMIT "+offset+","+limit;
  // Execute SQL
  let log_users:any = [];
  try {
    const sql = `
      SELECT id, created_at, userid, incident, logdetail
        FROM log_users
        ${whereclause}
        ORDER BY id ${sortclause}
        ${limitclause};
    `;
    const result:any = await dbconnect.execute(sql, argumentarr);
    if (Array.isArray(result) && (result.length > 0)) {
      log_users = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_log_users', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return log_users;
}

async function count_log_syss(
  datefrom: string,
  dateto: string,
  sysid: string, 
  f_incident: string, 
  logdetail: string,
) {
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (datefrom) {
    whereclause += " AND created_at >= ?";
    argumentarr.push(datefrom);
  }
  if (dateto) {
    whereclause += " AND created_at < ?";
    argumentarr.push(dateto);
  }
  if (sysid) {
    whereclause += " AND sysid = ?";
    argumentarr.push(sysid.trim());
  }
  if (f_incident) {
    whereclause += " AND incident LIKE ?";
    argumentarr.push('%'+f_incident.trim()+'%');
  }
  if (logdetail) {
    whereclause += " AND logdetail LIKE ?";
    argumentarr.push('%'+logdetail.trim()+'%');
  }
  // Execute SQL
  let RecordCount = 0;
  try {
    const sql = `
      SELECT COUNT(id) AS RecordCount
        FROM log_syss
        ${whereclause};
    `;
    const result:any = await dbconnect.execute(sql, argumentarr);
    if (Array.isArray(result) && (result.length > 0)) {
      RecordCount = xNumber(result[0].RecordCount);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':count_log_syss', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return RecordCount;
}

async function count_log_users(
  datefrom: string,
  dateto: string,
  userid: string, 
  f_incident: string, 
  logdetail: string,
) {
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (datefrom) {
    whereclause += " AND created_at >= ?";
    argumentarr.push(datefrom);
  }
  if (dateto) {
    whereclause += " AND created_at < ?";
    argumentarr.push(dateto);
  }
  if (userid) {
    whereclause += " AND userid = ?";
    argumentarr.push(userid.trim());
  }
  if (f_incident) {
    whereclause += " AND incident LIKE ?";
    argumentarr.push('%'+f_incident.trim()+'%');
  }
  if (logdetail) {
    whereclause += " AND logdetail LIKE ?";
    argumentarr.push('%'+logdetail.trim()+'%');
  }
  // Execute SQL
  let RecordCount = 0;
  try {
    const sql = `
      SELECT COUNT(id) AS RecordCount
        FROM log_users
        ${whereclause};
    `;
    const result:any = await dbconnect.execute(sql, argumentarr);
    if (Array.isArray(result) && (result.length > 0)) {
      RecordCount = xNumber(result[0].RecordCount);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':count_log_users', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return RecordCount;
}

export {
  add_log_sys,
  add_log_user,
  get_log_syss,
  get_log_users,
  count_log_syss,
  count_log_users,
}