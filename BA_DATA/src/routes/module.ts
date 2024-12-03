//################################# INCLUDE #################################
//---- System Modules ----
import express, { Router, Request, Response, NextFunction } from 'express';

//---- Application Modules ----
import K from '../engines/constant';
import { K_log_incident } from '../engines/localconst';
import { xString, xNumber, isData, sendObj } from '../engines/originutil';
import { verify_user } from '../engines/authutil';
import { add_log_user } from '../engines/logfunc';
import { 
  add_module,
  add_lesson,
  get_module,
  get_modules,
  get_lesson,
  get_lessons,
  update_module,
  update_lesson,
  delete_module,
  delete_lesson,
  delete_lessons,
  count_modules,
  count_lessons
} from '../engines/dbfunc';

//################################# DECLARATION #################################
const THIS_FILENAME = 'module.ts';

//################################# FUNCTION #################################


//################################# ROUTE #################################
const router: Router = express.Router();

/* define the HOME route */
router.get('/', (req: Request, res: Response) => {
  res.send('This is -Module- API endpoint.');
});

/* v----- all routes below this middleware will use Bearer Token -----v */
router.use(async (req: Request, res: Response, next: NextFunction) => {
  await verify_user(req, res, next);
});

/* define the Create-One route */
router.post('/', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      modulecode: string,
   *      title: string,
   *      caption: string,
   *      descr: string, 
   *      coverid: string,
   *      maturityrating: number,
   *      tags: string
   *    }
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: []
   *    }
   */
  const userid = xString(res.locals.userid);
  let modulecode = req.body.modulecode;
  let title = req.body.title;
  let caption = req.body.caption;
  let descr = req.body.descr;
  let coverid = req.body.coverid;
  let maturityrating = req.body.maturityrating;
  let tags = req.body.tags;
  if (!(isData(modulecode) && isData(title) && isData(maturityrating))) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  modulecode = xString(modulecode);
  title = xString(title);
  caption = xString(caption);
  descr = xString(descr);
  coverid = xString(coverid);
  maturityrating = xNumber(maturityrating);
  tags = xString(tags);
  const id = await add_module(modulecode, title, caption, descr, coverid, maturityrating, tags);
  if ((id == K.SYS_INTERNAL_PROCESS_ERROR) || (!id)) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- Event Log
  const logdetail = JSON.stringify({
    id: id,
  });
  await add_log_user(userid, K_log_incident.MODULE_ADD, logdetail);
  // -- Done
  sendObj(1, 'ok', [], res);
});

/* define the Create-Lesson-One route */
router.post('/lesson', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      lessoncode: string,
   *      module_id: number,
   *      lessonno: number,
   *      title: string,
   *      descr: string,
   *      coverid: string,
   *      contentid: string,
   *      mediaid: string,
   *      tags: string
   *    }
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: []
   *    }
   */
  const userid = xString(res.locals.userid);
  let lessoncode = req.body.lessoncode;
  let module_id = req.body.module_id;
  let lessonno = req.body.lessonno;
  let title = req.body.title;
  let descr = req.body.descr;
  let coverid = req.body.coverid;
  let contentid = req.body.contentid;
  let mediaid = req.body.mediaid;
  let tags = req.body.tags;
  if (!(isData(lessoncode) && isData(module_id) && isData(lessonno) && isData(title) && isData(contentid))) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  lessoncode = xString(lessoncode);
  module_id = xNumber(module_id);
  lessonno = xNumber(lessonno);
  title = xString(title);
  descr = xString(descr);
  coverid = xString(coverid);
  contentid = xString(contentid);
  mediaid = xString(mediaid);
  tags = xString(tags);
  const id = await add_lesson(lessoncode, module_id, lessonno, title, descr, coverid, contentid, mediaid, tags);
  if ((id == K.SYS_INTERNAL_PROCESS_ERROR) || (!id)) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- Event Log
  const logdetail = JSON.stringify({
    id: id,
  });
  await add_log_user(userid, K_log_incident.LESSON_ADD, logdetail);
  // -- Done
  sendObj(1, 'ok', [], res);
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
   *          moduleid: "a303e760-db75-4692-a2e4-d2dad892f5f9",
   *          modulecode: "MOD001",
   *          ...
   *        }
   *      ]
   *    }
   */
  const id = xNumber(req.params.id);
  const modules = await get_module(id);
  if (modules == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  if (modules.length == 0) {
    sendObj(2, 'Internal process error', [], res)
    return;
  }
  sendObj(1, 'ok', modules, res);
});

/* define the Read-Lesson-One route */
router.get('/lesson/id/:id', async (req: Request, res: Response) => {
  /**
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: [
   *        {
   *          lessonid: "a303e760-db75-4692-a2e4-d2dad892f5f9",
   *          lessoncode: "LES001",
   *          ...
   *        }
   *      ]
   *    }
   */
  const id = xNumber(req.params.id);
  const lessons = await get_lesson(id);
  if (lessons.length == 0) {
    sendObj(2, 'Internal process error', [], res)
    return;
  }
  sendObj(1, 'ok', lessons, res);
});

/* define the Read-Filter route */
router.post('/filter', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      limit: number,
   *      page: number, // 1,2,...
   *      sort: string, // "asc", "desc" ; default = ""
   *      belocked: any,
   *      becancelled: any,
   *      docstatus: any,
   *      modulecode: string, 
   *      title: string,
   *      caption: string,
   *      descr: string, 
   *      maturityrating: any,
   *      tags: string
   *    }
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: [
   *        {
   *          id: 1,
   *          modulecode: "MOD001",
   *          ...
   *        },
   *        ...
   *      ]
   *    }
   */
  const limit = xNumber(req.body.limit); 
  const page = xNumber(req.body.page);
  const sort = xString(req.body.sort);
  const belocked = req.body.belocked;
  const becancelled = req.body.becancelled;
  const docstatus = req.body.docstatus;
  const modulecode = xString(req.body.modulecode);
  const title = xString(req.body.title);
  const caption = xString(req.body.caption);
  const descr = xString(req.body.descr);
  const maturityrating = req.body.maturityrating;
  const tags = xString(req.body.tags);
  if (!(limit && page)) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  if ((limit <= 0) || (page <= 0)) {
    sendObj(5, 'Incorrect pagination fields', [], res);
    return;
  }
  const modules = await get_modules(belocked, becancelled, docstatus, modulecode, title, caption, descr, maturityrating, tags, {
    limit: limit,
    page: page,
    sort: sort,
  });
  if (modules == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  sendObj(1, 'ok', modules, res);
});

/* define the Read-Lesson-Filter route */
router.post('/lesson/filter', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      limit: number,
   *      page: number, // 1,2,...
   *      sort: string, // "asc", "desc" ; default = ""
   *      module_id: number,
   *      lessoncode: string,
   *      title: string,
   *      descr: string,
   *      tags: string
   *    }
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: [
   *        {
   *          id: 1,
   *          lessoncode: "LES001",
   *          lessonno: 1,
   *          ...
   *        },
   *        ...
   *      ]
   *    }
   */
  const limit = xNumber(req.body.limit); 
  const page = xNumber(req.body.page);
  const sort = xString(req.body.sort);
  const module_id = xNumber(req.body.module_id);
  const lessoncode = xString(req.body.lessoncode);
  const title = xString(req.body.title);
  const descr = xString(req.body.descr);
  const tags = xString(req.body.tags);
  if (!(limit && page && module_id)) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  if ((limit <= 0) || (page <= 0)) {
    sendObj(5, 'Incorrect pagination fields', [], res);
    return;
  }
  const lessons = await get_lessons(module_id, lessoncode, title, descr, tags, {
    limit: limit,
    page: page,
    sort: sort,
  });
  if (lessons == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  sendObj(1, 'ok', lessons, res);
});

/* define the Read-Count route */
router.post('/count', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      belocked: any,
   *      becancelled: any,
   *      docstatus: any,
   *      modulecode: string, 
   *      title: string,
   *      caption: string,
   *      descr: string, 
   *      maturityrating: any,
   *      tags: string
   *    }
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: [
   *        {
   *          RecordCount: 8
   *        }
   *      ]
   *    }
   */
  const belocked = req.body.belocked;
  const becancelled = req.body.becancelled;
  const docstatus = req.body.docstatus;
  const modulecode = xString(req.body.modulecode);
  const title = xString(req.body.title);
  const caption = xString(req.body.caption);
  const descr = xString(req.body.descr);
  const maturityrating = req.body.maturityrating;
  const tags = xString(req.body.tags);
  const RecordCount = await count_modules(belocked, becancelled, docstatus, modulecode, title, caption, descr, maturityrating, tags);
  if (RecordCount == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  sendObj(1, 'ok', [{ RecordCount: RecordCount }], res);
});

/* define the Read-Lesson-Count route */
router.post('/lesson/count', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      module_id: number,
   *      lessoncode: string,
   *      title: string,
   *      descr: string,
   *      tags: string
   *    }
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: [
   *        {
   *          RecordCount: 8
   *        }
   *      ]
   *    }
   */
  const module_id = xNumber(req.body.module_id);
  const lessoncode = xString(req.body.lessoncode);
  const title = xString(req.body.title);
  const descr = xString(req.body.descr);
  const tags = xString(req.body.tags);
  if (!(module_id)) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  const RecordCount = await count_lessons(module_id, lessoncode, title, descr, tags);
  if (RecordCount == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  sendObj(1, 'ok', [{ RecordCount: RecordCount }], res);
});

/* define the Update-One route */
router.put('/id/:id', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      modulecode: string,
   *      title: string,
   *      caption: string,
   *      descr: string, 
   *      coverid: string,
   *      maturityrating: number,
   *      tags: string
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
  let modulecode = req.body.modulecode;
  let title = req.body.title;
  let caption = req.body.caption;
  let descr = req.body.descr;
  let coverid = req.body.coverid;
  let maturityrating = req.body.maturityrating;
  let tags = req.body.tags;
  if (!(isData(modulecode) && isData(title) && isData(maturityrating))) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  modulecode = xString(modulecode);
  title = xString(title);
  caption = xString(caption);
  descr = xString(descr);
  coverid = xString(coverid);
  maturityrating = xNumber(maturityrating);
  tags = xString(tags);
  let affectedRows = await update_module(id, modulecode, title, caption, descr, coverid, maturityrating, tags);
  if ((affectedRows == K.SYS_INTERNAL_PROCESS_ERROR) || (!affectedRows)) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- Event Log
  const logdetail = JSON.stringify({
    id: id,
  });
  await add_log_user(userid, K_log_incident.MODULE_EDIT, logdetail);
  // -- Done
  sendObj(1, 'ok', [], res);
});

/* define the Update-Lesson-One route */
router.put('/lesson/id/:id', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      lessoncode: string,
   *      module_id: number,
   *      lessonno: number,
   *      title: string,
   *      descr: string,
   *      coverid: string,
   *      contentid: string,
   *      mediaid: string,
   *      tags: string
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
  let lessoncode = req.body.lessoncode;
  let module_id = req.body.module_id;
  let lessonno = req.body.lessonno;
  let title = req.body.title;
  let descr = req.body.descr;
  let coverid = req.body.coverid;
  let contentid = req.body.contentid;
  let mediaid = req.body.mediaid;
  let tags = req.body.tags;
  if (!(isData(lessoncode) && isData(module_id) && isData(lessonno) && isData(title) && isData(contentid))) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  lessoncode = xString(lessoncode);
  module_id = xNumber(module_id);
  lessonno = xNumber(lessonno);
  title = xString(title);
  descr = xString(descr);
  coverid = xString(coverid);
  contentid = xString(contentid);
  mediaid = xString(mediaid);
  tags = xString(tags);
  let affectedRows = await update_lesson(id, lessoncode, module_id, lessonno, title, descr, coverid, contentid, mediaid, tags);
  if ((affectedRows == K.SYS_INTERNAL_PROCESS_ERROR) || (!affectedRows)) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- Event Log
  const logdetail = JSON.stringify({
    id: id,
  });
  await add_log_user(userid, K_log_incident.LESSON_EDIT, logdetail);
  // -- Done
  sendObj(1, 'ok', [], res);
});

/* define the Delete-One route */
router.delete('/id/:id', async (req: Request, res: Response) => {
  /**
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: []
   *    }
   */
  const userid = xString(res.locals.userid);
  const id = xNumber(req.params.id);
  // -- table: lessons
  let affectedRows = await delete_lessons(id);
  if (affectedRows == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- table: modules
  affectedRows = await delete_module(id);
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
    id: id,
  });
  await add_log_user(userid, K_log_incident.MODULE_DEL, logdetail);
  // -- Done
  sendObj(1, 'ok', [], res);
});

/* define the Delete-Lesson-One route */
router.delete('/lesson/id/:id', async (req: Request, res: Response) => {
  /**
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: []
   *    }
   */
  const userid = xString(res.locals.userid);
  const id = xNumber(req.params.id);
  let affectedRows = await delete_lesson(id);
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
    id: id,
  });
  await add_log_user(userid, K_log_incident.LESSON_DEL, logdetail);
  // -- Done
  sendObj(1, 'ok', [], res);
});

export default router;