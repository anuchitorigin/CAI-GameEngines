//################################# INCLUDE #################################
//---- System Modules ----
import express, { Router, Request, Response, NextFunction } from 'express';

//---- Application Modules ----
import K from '../engines/constant';
import { K_log_incident } from '../engines/localconst';
import { xString, xNumber, isData, sendObj } from '../engines/originutil';
import { verify_user } from '../engines/authutil';
import { get_sysvar_varvalue } from '../engines/datautil';
import { add_log_user } from '../engines/logfunc';
import { 
  get_sysvar,
  get_sysvars,
  update_sysvar,
} from '../engines/dbfunc';

//################################# DECLARATION #################################
const THIS_FILENAME = 'sysvar.ts';

//################################# FUNCTION #################################


//################################# ROUTE #################################
const router: Router = express.Router();

/* define the HOME route */
router.get('/', (req: Request, res: Response) => {
  res.send('This is -System Variable- API endpoint.');
});

/* v----- all routes below this middleware will use Bearer Token -----v */
router.use(async (req: Request, res: Response, next: NextFunction) => {
  await verify_user(req, res, next);
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
   *          id: 1,
   *          varid: "TIME_ZONE",
   *          ...
   *        },
   *        ...
   *      ]
   *    }
   */
  const sysvars = await get_sysvars();
  if (sysvars == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  sendObj(1, 'ok', sysvars, res);
});

/* define the Read-One route */
router.get('/id/:id', async (req: Request, res: Response) => {
  /**
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: [
   *        {
   *          varid: "TIME_ZONE",
   *          ...
   *        }
   *      ]
   *    }
   */
  const id = xNumber(req.params.id);
  const sysvars = await get_sysvar(id);
  if (sysvars == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  if (sysvars.length == 0) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  sendObj(1, 'ok', sysvars, res);
});

/* define the Read-Value route */
router.get('/value/:varid', async (req: Request, res: Response) => {
  /**
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: [
   *        {
   *          id: 1,
   *          varname: "Time Zone Offset",
   *          ...
   *        }
   *      ]
   *    }
   */
  const varid = xString(req.params.varid);
  const varvalue = await get_sysvar_varvalue(varid);
  if (varvalue == undefined) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  sendObj(1, 'ok', [{ varvalue: varvalue }], res);
});

/* define the Update-One route */
router.put('/id/:id', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      varname: string, 
   *      descr: string,
   *      varvalue: string
   *    }
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: []
   *    }
   */
  const userid = xString(res.locals.userid);
  const id = xNumber(req.params.id);
  let varname = req.body.varname;
  let descr = req.body.descr;
  let varvalue = req.body.varvalue;
  if (!(isData(varname) && isData(descr) && isData(varvalue))) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  varname = xString(varname);
  descr = xString(descr);
  varvalue = xString(varvalue);
  const affectedRows = await update_sysvar(id, varname, descr, varvalue);
  if ((affectedRows == K.SYS_INTERNAL_PROCESS_ERROR) || (!affectedRows)) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- Event Log
  const logdetail = JSON.stringify({
    id: id,
  });  
  await add_log_user(userid, K_log_incident.SYSVAR_EDIT, logdetail);
  // -- Done
  sendObj(1, 'ok', [], res);
});

export default router;