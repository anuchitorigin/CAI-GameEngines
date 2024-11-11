//################################# INCLUDE #################################
//---- System Modules ----
import express, { Router, Request, Response } from 'express';

//---- Application Modules ----
import K from '../engines/constant';
import { K_SYSID, K_log_incident } from '../engines/localconst';
import { xString, random_password, get_hashed, isData, sendObj } from '../engines/originutil';
import { 
  add_token, 
  get_user_by_userid,
  encode_jwt, 
  decode_jwt, 
  verify_auth 
} from '../engines/authutil';
import { add_log_sys, add_log_user } from '../engines/logfunc';
import { 
  add_user,
  get_user, 
  get_user_id_from_signup, 
  get_user_id_credential, 
  reset_passcode, 
  change_passcode
} from '../engines/dbfunc';

//################################# DECLARATION #################################
const THIS_FILENAME = 'local.ts';

//################################# FUNCTION #################################


//################################# ROUTE #################################
const router: Router = express.Router();

/* define the HOME route */
router.get('/', (req: Request, res: Response) => {
  res.send('This is -Local- API endpoint.');
});

/* define the Login route */
router.post('/login', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      loginid: string,
   *      passcode: string,
   *      callerip: string,
   *      callername: string
   *    }
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: [
   *        {
   *          token: aaaa.bbbb.cccc
   *        }
   *      ]
   *    }
   */
  const loginid = xString(req.body.loginid);
  const passcode = xString(req.body.passcode);
  const callerip = xString(req.body.callerip);
  const callername = xString(req.body.callername);
  if (!(loginid && passcode && callerip && callername)) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  // -- Check Credential
  const id = await get_user_id_credential(loginid, passcode);
  if (id == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  if (!id) {
    sendObj(3000, 'Invalid login name or password', [], res);
    return;
  }
  // -- Create Token
  const token = await add_token(id, callerip, callername, 'login');
  if (!token) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  const wrapped_token = encode_jwt(token);
  // -- Event Log
  const user = await get_user(id);
  if ((user == K.SYS_INTERNAL_PROCESS_ERROR) || (!user)) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  const logdetail = '{}';
  await add_log_user(user.userid, K_log_incident.AUTH_LOGIN, logdetail);
  // -- Done
  sendObj(1, 'ok', [{ token: wrapped_token }], res);
});

/* define the Signup route */
router.post('/signup', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      loginid: string,
   *      roleid: string,
   *      firstname: string,
   *      lastname: string
   *    }
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: [{
   *        loginid: string,
   *        passcode: string
   *      }]
   *    }
   */
  let loginid = req.body.loginid;
  let roleid = req.body.roleid;
  let firstname = req.body.firstname;
  let lastname = req.body.lastname;
  if (!(isData(loginid) && isData(roleid) && isData(firstname))) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  loginid = xString(loginid);
  roleid = xString(roleid);
  firstname = xString(firstname);
  // -- Check User
  const check_user = await get_user_id_from_signup(loginid);
  if (check_user == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  if (check_user) {
    sendObj(3001, 'This login name has been used', [], res);
    return;
  }
  // -- Create User
  const randompasscode = (random_password(8));
  const passcode = get_hashed(randompasscode);
  const user_id = await add_user(loginid, passcode, roleid, firstname, lastname);
  if ((user_id == K.SYS_INTERNAL_PROCESS_ERROR) || (!user_id)) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- Event Log
  const user = await get_user(user_id);
  if ((user == K.SYS_INTERNAL_PROCESS_ERROR) || (!user)) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  const logdetail = JSON.stringify({
    loginid: loginid,
    userid: user.userid
  });
  await add_log_sys(K_SYSID, K_log_incident.AUTH_SIGNUP, logdetail);
  // -- Done
  sendObj(1, 'ok', [{
    loginid: loginid,
    passcode: randompasscode
  }], res);
});

/* define the Reset-Password route */
router.post('/resetpass', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      id_token: string,
   *      userid: string, // leave if the userid is the owner of id_token
   *    }
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: []
   *    }
   */
  const id_token = xString(req.body.id_token);
  let userid = req.body.userid;
  if (!(id_token)) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  userid = xString(userid);
  const { sessionid: sessionid, accesstoken: accesstoken } = decode_jwt(id_token);
  if (!(sessionid && accesstoken)) {
    sendObj(4, 'Invalid request', [], res);
    return;
  }
  // -- Check Request User
  const { userid: requestuserid } = await verify_auth(sessionid, accesstoken);
  if (!requestuserid) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- Check User
  if (!userid) {
    userid = requestuserid;
  }
  const user = await get_user_by_userid(userid);
  if (user.length == 0) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- Update User
  const user_id = user[0].id;
  const randompasscode = (random_password(8));
  const passcode = get_hashed(randompasscode);
  const affectedRows = await reset_passcode(user_id, passcode);
  if (!affectedRows) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- Event Log
  const logdetail = JSON.stringify({
    requestuserid: requestuserid,
    userid: userid
  });
  await add_log_user(userid, K_log_incident.AUTH_RESET, logdetail);
  // -- Done
  sendObj(1, 'ok', [{
    passcode: randompasscode
  }], res);
});

/* define the Change-Password route */
router.post('/changepass', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      id_token: string,
   *      oldpass: string,
   *      newpass: string
   *    }
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: []
   *    }
   */
  const id_token = xString(req.body.id_token);
  const oldpass = xString(req.body.oldpass);
  const newpass = xString(req.body.newpass);
  if (!(id_token && oldpass && newpass)) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  const { sessionid: sessionid, accesstoken: accesstoken } = decode_jwt(id_token);
  if (!(sessionid && accesstoken)) {
    sendObj(4, 'Invalid request', [], res);
    return;
  }
  // -- Check User
  const { userid: userid, user_id: user_id } = await verify_auth(sessionid, accesstoken);
  if (!userid) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- Change Passcode
  const affectedRows = await change_passcode(user_id, oldpass, newpass, sessionid);
  if ((affectedRows == K.SYS_INTERNAL_PROCESS_ERROR) || (!affectedRows)) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- Event Log
  const logdetail = '{}';
  await add_log_user(userid, K_log_incident.AUTH_CHANGE, logdetail);
  // -- Done
  sendObj(1, 'ok', [], res);
});

export default router;