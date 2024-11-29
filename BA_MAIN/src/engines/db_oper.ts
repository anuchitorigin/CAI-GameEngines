/**
 *  Program:      DB_OPER Connection
 *  Description:  Connection functions for DB access
 *  Version:      1.0.0
 *  Updated:      5 Aug 2024
 *  Programmer:   Mr. Anuchit Butkhunthong
 *  E-mail:       anuchit.b@origin55.com
 *  Update Information:
 *    * Version  1.0.0 (5 Aug 2024)
 *      - Prepare for V1
 */

//################################# INCLUDE #################################
//---- System Modules ----
import mariadb from 'mariadb';

//---- Application Modules ----
import env from './env';

//################################# DECLARATION #################################
const pool:mariadb.Pool = mariadb.createPool({
  host: env.DB_HOST,
  port: env.DB_PORT,
  user: env.DB_USER,
  password: env.DB_ROOT_PASSWORD,
  database: env.OPER_DATABASE,
  connectionLimit: env.DB_POOL_LIMIT,
});

//################################# FUNCTION #################################
async function execute(sql: string, data: any[]) {
  let result = null;
  let poolconnect;
  try {
    poolconnect = await pool.getConnection();
    result = await poolconnect.execute(sql, data);
  } finally {
    if (poolconnect) {
      poolconnect.release(); //release to pool
    } 
  }
  return result;
}

function escape(data: any) {
  return pool.escape(data);
}

export default {
  pool,
  execute,
  escape,
}