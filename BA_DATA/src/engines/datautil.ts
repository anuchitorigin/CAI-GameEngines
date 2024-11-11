/**
 *  Program:      Data Utility for TS
 *  Description:  All functions are included for data process
 *  Version:      1.1.0
 *  Updated:      22 Jul 2024
 *  Programmer:   Mr. Anuchit Butkhunthong
 *  E-mail:       anuchit.b@origin55.com
 *  Update Information:
 *    * Version  1.1.0 (22 Jul 2024)
 *      - add functions for content data
 *    * Version  1.0.0 (18 Jul 2024)
 *      - Prepare for V1
 */

//################################# INCLUDE #################################
//---- System Modules ----
// import path from 'path';

//---- Application Modules ----
import K from './constant';
import dbconnect from './db_data';
import { xNumber, incident } from './originutil';

//################################# DECLARATION #################################
const THIS_FILENAME = 'datautil.ts';

//################################# FUNCTION #################################
async function add_bucket(prefix: string, bucketname: string, buckettype: string, bucketdata: string) {
  const bucketid = prefix+crypto.randomUUID();
  let id = 0;
  try {
    const sql = `
      INSERT INTO buckets
        (bucketid, bucketname, buckettype, bucketdata)
        VALUES
        (?,?,?,?)
        RETURNING id;
    `;
    const result = await dbconnect.execute(sql, [
      bucketid,
      bucketname,
      buckettype,
      bucketdata
    ]); 
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':add_bucket', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  if (!id) {
    return '';
  }
  return bucketid;
}

async function add_content(prefix: string, bucketname: string, buckettype: string, bucketdata: string) {
  const bucketid = prefix+crypto.randomUUID();
  let id = 0;
  try {
    const sql = `
      INSERT INTO contents
        (bucketid, bucketname, buckettype, bucketdata)
        VALUES
        (?,?,?,?)
        RETURNING id;
    `;
    const result = await dbconnect.execute(sql, [
      bucketid,
      bucketname,
      buckettype,
      bucketdata
    ]); 
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':add_content', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  if (!id) {
    return '';
  }
  return bucketid;
}

async function get_sysvar_varvalue(varid: string) {
  let varvalue = undefined;
  try {
    let sql = `
      SELECT varvalue
        FROM sysvars
        WHERE varid = ?
        ORDER BY id DESC
        LIMIT 1;
    `;
    const result:any = await dbconnect.execute(sql, [
      varid
    ]);
    if (Array.isArray(result) && (result.length > 0)) {
      varvalue = result[0].varvalue;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_sysvar_varvalue', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return varvalue;
}

async function get_bucket(bucketid: string) {
  let buckets = [];
  try {
    const sql = `
      SELECT bucketname, buckettype, bucketdata 
        FROM buckets
        WHERE bucketid = ?
        ORDER BY id DESC
        LIMIT 1;
    `;
    const result = await dbconnect.execute(sql, [
      bucketid
    ]);
    if (result.length > 0) {
      buckets = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_bucket', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return buckets;
}

async function get_content(bucketid: string) {
  let contents = [];
  try {
    const sql = `
      SELECT bucketname, buckettype, bucketdata 
        FROM contents
        WHERE bucketid = ?
        ORDER BY id DESC
        LIMIT 1;
    `;
    const result = await dbconnect.execute(sql, [
      bucketid
    ]);
    if (result.length > 0) {
      contents = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_content', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return contents;
}

async function delete_bucket(bucketid: string) {
  let affectedRows = 0;
  try {
    const sql = `
      DELETE FROM buckets 
        WHERE bucketid = ?;
    `;
    const result = await dbconnect.execute(sql, [
      bucketid
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':delete_bucket', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function delete_content(bucketid: string) {
  let affectedRows = 0;
  try {
    const sql = `
      DELETE FROM contents 
        WHERE bucketid = ?;
    `;
    const result = await dbconnect.execute(sql, [
      bucketid
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':delete_content', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

export {
  add_bucket,
  add_content,
  get_sysvar_varvalue,
  get_bucket,
  get_content,
  delete_bucket,
  delete_content
}