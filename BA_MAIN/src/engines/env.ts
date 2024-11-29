/**
 *  Program:      Environment Variables for TS
 *  Description:  All variables from .env file
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
import dotenv from 'dotenv';

//---- Application Modules ----
import { xString, xNumber } from './originutil';

//################################# DECLARATION #################################
dotenv.config();

const env = {
  DB_HOST: xString(process.env.DB_HOST),
  DB_PORT: xNumber(process.env.DB_PORT) || 3306,
  DB_USER: xString(process.env.DB_USER),
  DB_ROOT_PASSWORD: xString(process.env.DB_ROOT_PASSWORD),
  AUTH_DATABASE: xString(process.env.AUTH_DATABASE),
  LOG_DATABASE: xString(process.env.LOG_DATABASE),
  DATA_DATABASE: xString(process.env.DATA_DATABASE),
  STORE_DATABASE: xString(process.env.STORE_DATABASE),
  OPER_DATABASE: xString(process.env.OPER_DATABASE),
  DB_POOL_LIMIT: xNumber(process.env.DB_POOL_LIMIT) || 1,
  JWT_SECRET: xString(process.env.JWT_SECRET),
  AUTH_TIMEOUT: xNumber(process.env.AUTH_TIMEOUT),
}

export default env