/**
 *  Program:      ORIGIN's Utility for TS
 *  Description:  All functions are included for general purposes
 *  Version:      1.0.9
 *  Updated:      13 Mar 2024
 *  Programmer:   Mr. Anuchit Butkhunthong
 *  E-mail:       anuchit.b@origin55.com
 *  Update Information:
 *    * Version 1.0.9 (13 Mar 2024)
 *      - modify function dateToSQL
 *    * Version 1.0.8 (29 Jun 2023)
 *      - add function toSQL_LIKE
 *    * Version 1.0.7 (4 Jun 2023)
 *      - add function toArray
 *    * Version 1.0.6 (27 May 2023)
 *      - add function addSeconds
 *      - add constant _SECOND_MS
 *      - change variable name -> _MINUTE_MS, _HOUR_MS, _DAY_MS, _PASSWORD_CHARSETs
 *    * Version 1.0.5 (1 Apr 2023)
 *      - change function name xString, xNumber, toBoolean, toDate
 *        to xString, xNumber, xBoolean, xDate
 *      - add function union
 *    * Version 1.0.4 (30 Mar 2023)
 *      - add function toNumericChar
 *      - add function isData
 *      - add function append_comma
 *    * Version 1.0.3 (20 Mar 2023)
 *      - add function extract_bearer
 *      - add function toDate
 *    * Version 1.0.2 (16 Mar 2023)
 *      - add function toString
 *      - add function toNumber
 *    * Version 1.0.1 (6 Mar 2023)
 *      - add function random_password
 *      - add function get_hashed
 *    * Version 1.0.0 (19 Feb 2023)
 *      - Prepare for V1
 */

//################################# INCLUDE #################################
import crypto from 'crypto';

//################################# DECLARATION #################################
const _SECOND_MS = 1000;
const _MINUTE_MS = 60000;
const _HOUR_MS = 3600000;
const _DAY_MS = 86400000;
const _PASSWORD_CHARSET = '!#$%&0123456789@ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

interface ResponseObj {
  status: number,
  message: string,
  result: any
}

//################################# CONVERSION #################################
function xString(a: any) {
  const t = typeof a;
  if ((t == 'undefined') || (t == 'object') || (t == 'function')) {
    return '';
  }
  return String(a);
}

function xNumber(a: any) {
  const t = typeof a;
  if ((t == 'undefined') || (t == 'object') || (t == 'function')) {
    return 0;
  }
  let n = Number(a);
  if (isNaN(n)) {
    n = 0;
  }
  return n;
}

function xBoolean(s: string) {
  let b = false;
  const c = s.toLowerCase();
  if ((c == 'true') || (c == '1')) {
    b = true;
  }
  return b;
}

function xDate(a: any) {
  let d = new Date(a);
  if (d.toString().toLowerCase() == 'invalid date') {
    return new Date(0);
  }
  return d;
}

function toNumericChar(a: any) {
  let c = '';
  const s = String(a);
  const n = Number(s);
  if (!isNaN(n)) {
    c = s;
  }
  return c;
}

function toArray(s: string) {
  let arr = [];
  try {
    arr = JSON.parse(s);
  } catch (err) {
    // do nothing
  }
  if (!Array.isArray(arr)) {
    arr = [];
  }
  return arr;
}

function toSQL_LIKE(s: string) {
  return s.trim().replace(/%/gi, '\\%').replace(/_/gi, '\\_');
}

//################################# CHARACTER/STRING #################################
function zeroPad(num: number, places: number) {
  return String(num).padStart(places, '0');
}

function append_comma(current: string, append: string) {
  let comma = '';
  if (current.trim()) {
    comma = ',';
  }
  return current+comma+append;
}

function random_password(places: number) {
  let password = '';
  for (let i = 0, l = _PASSWORD_CHARSET.length; i < places; i++) {
    password += _PASSWORD_CHARSET.charAt(Math.floor(Math.random() * l));
  }
  return password;
}

function get_hashed(password: string) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

function extract_bearer(bearerHeader: string) {
  const bearer = bearerHeader.split(' ');
  const bearerType = bearer[0];
  const bearerToken = bearer[1];
  if ((bearerType != 'Bearer') || (!bearerToken)) {
    return '';
  }
  return bearerToken;
}

//################################# DATE/TIME #################################
function addSeconds(seconds: number, date = new Date()) {
  return date.setTime(date.getTime() + seconds*_SECOND_MS);
}

function addMinutes(minutes: number, date = new Date()) {
  return date.setTime(date.getTime() + minutes*_MINUTE_MS);
}

function addHours(hours: number, date = new Date()) {
  return date.setTime(date.getTime() + hours*_HOUR_MS);
}

function getNowFormat(region: string, timezone: string) {
  const dateOptions: Intl.DateTimeFormatOptions = {
    year: 'numeric', month: 'numeric', day: 'numeric',
    hour: 'numeric', minute: 'numeric', second: 'numeric',
    hour12: false,
    timeZone: timezone
  };
  return new Intl.DateTimeFormat(region, dateOptions).format(Date.now());
}

function diffDays(date1: Date, date2: Date) {
  let d1 = Number(date1);
  let d2 = Number(date2);
  return Math.round((d2 - d1)/_DAY_MS);
}

function dateToSQL(date = new Date(), timezoneoffset: boolean = false) {
  let d = new Date(date);
  if (timezoneoffset) {
    let tzo = d.getTimezoneOffset() * (-1);
    addMinutes(tzo, d);
  }
  return d.toISOString().replace('T', ' ').replace('Z', '');
}

//################################# VALIDATION #################################
function isData(a: any) {
  let b = true;
  if ((a === null) || (a === undefined)) {
    b = false;
  }
  return b;
}

//################################# ARRAY #################################
function union(arr: Array<any>, a: any) {
  if ((a === null) || (a === undefined)) {
    return 0;
  }
  const f = arr.find((x) => (x === a));
  if (f === undefined) {
    return arr.push(a);
  }
  return 0;
}

//################################# SYSTEM #################################
function sleep(ms: number) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function sendObj(status: number, message: string, result: any, respose: any) {
  const responseObj: ResponseObj = {
    status: status,
    message: message,
    result: result
  }
  respose.send(responseObj);
}

function incident(source: string, detail: string) {
  return '['+getNowFormat('th', 'Asia/Bangkok')+'] <'+source+'> '+detail;
}

export {
  xString,
  xNumber,
  xBoolean,
  xDate,
  toNumericChar,
  toArray,
  toSQL_LIKE,
  zeroPad,
  append_comma,
  random_password,
  get_hashed,
  extract_bearer,
  addSeconds,
  addMinutes,
  addHours,
  getNowFormat,
  diffDays,
  dateToSQL,
  isData,
  union,
  sleep,
  sendObj,
  incident
}