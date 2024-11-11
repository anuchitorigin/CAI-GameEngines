//################################# INCLUDE #################################
//---- System Modules ----
import express, { Router, Request, Response, NextFunction } from 'express';

//---- Application Modules ----
import K from '../engines/constant';
import { K_log_incident } from '../engines/localconst';
import { xString, isData, sendObj } from '../engines/originutil';
import { get_user_by_userid, get_profile, verify_user } from '../engines/authutil';
import { add_log_user } from '../engines/logfunc';
import { 
  get_users, 
  get_roles,
  update_user, 
  delete_user,
} from '../engines/userfunc';

//################################# DECLARATION #################################
const THIS_FILENAME = 'user.ts';

//################################# FUNCTION #################################


//################################# ROUTE #################################
const router: Router = express.Router();

/* define the HOME route */
router.get('/', (req: Request, res: Response) => {
  res.send('This is -User- API endpoint.');
});

/* v----- all routes below this middleware will use Bearer Token -----v */
router.use(async (req: Request, res: Response, next: NextFunction) => {
  await verify_user(req, res, next);
});

/* define the Read-Role-All route */
router.get('/role/all', async (req, res) => {
  /**
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: [
   *        {
   *          roleid: "xxx"
   *          ...
   *        },
   *        ...
   *      ]
   *    }
   */
  const roles = await get_roles();
  if (roles == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  sendObj(1, 'ok', roles, res);
});

/* define the Read-All route */
router.get('/all', async (req: Request, res: Response) => {
  /**
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: [
   *        {
   *          userid: "xxx"
   *          ...
   *        },
   *        ...
   *      ]
   *    }
   */
  const users = await get_users();
  if (users == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  sendObj(1, 'ok', users, res);
});

/* define the Read-Profile route */
router.get('/profile', async (req: Request, res: Response) => {
  /**
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: [
   *        {
   *          userid: "d69fd456-74e3-41de-a9f1-af8e6083fd51",
   *          loginid: "noobfic",
   *          roleparam: "{"user":1}",
   *          firstname: "NoobFic",
   *          lastname: "Fan",
   *          expired_at: "2023-03-20T14:38:40.000Z", // ISO 8601
   *        }
   *      ]
   *    }
   */
  const userid = xString(res.locals.userid);
  const user = await get_profile(userid);
  if (user.length == 0) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  sendObj(1, 'ok', user, res);
});

/* define the Read-One route */
router.get('/id/:userid', async (req: Request, res: Response) => {
  /**
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: [
   *        {
   *          loginid: "noobfic",
   *          roleparam: "{"user":1}",
   *          firstname: "NoobFic",
   *          lastname: "Fan"
   *        }
   *      ]
   *    }
   */
  const p_userid = xString(req.params.userid);
  const users = await get_user_by_userid(p_userid);
  if (users == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  if (users.length == 0) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  sendObj(1, 'ok', users, res);
});

/* define the Update-One route */
router.post('/id/:userid', async (req, res) => {
  /**
   *  Request:-
   *    {
   *      roleparam: string,
   *      firstname: string,
   *      lastname: string,
   *      employeeid: string,
   *      remark: string
   *    }
   */
  const userid = xString(res.locals.userid);
  const p_userid = xString(req.params.userid);
  let roleparam = req.body.roleparam;
  let firstname = req.body.firstname;
  let lastname = req.body.lastname;
  let employeeid = req.body.employeeid;
  let remark = req.body.remark;
  if (!(isData(roleparam) && isData(firstname))) {
    sendObj(0, 'Insufficient required fields', [], res);
    return;
  }
  roleparam = xString(roleparam);
  firstname = xString(firstname);
  const affectedRows = await update_user(p_userid, roleparam, firstname, lastname, employeeid, remark);
  if (affectedRows == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  if (!affectedRows) {
    sendObj(11, 'Unable to update', [], res);
    return;
  }
  // -- Event Log
  const logdetail = JSON.stringify({
    userid: p_userid,
  });
  await add_log_user(userid, K_log_incident.USER_EDIT, logdetail);
  // -- Done
  sendObj(1, 'ok', [], res);
});

/* define the Delete-One route */
router.delete('/id/:userid', async (req: Request, res: Response) => {
  /**
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: []
   *    }
   */
  const userid = xString(res.locals.userid);
  const p_userid = xString(req.params.userid);
  const affectedRows = await delete_user(p_userid);
  if (affectedRows == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  if (!affectedRows) {
    sendObj(11, 'Unable to delete', [], res);
    return;
  }
  // -- Event Log
  const logdetail = JSON.stringify({
    userid: p_userid,
  });  
  await add_log_user(userid, K_log_incident.USER_DEL, logdetail);
  // -- Done
  sendObj(1, 'ok', [], res);
});

export default router;