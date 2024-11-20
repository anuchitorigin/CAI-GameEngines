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
  add_exam,
  add_quiz,
  add_choice,
  get_exam,
  get_exams,
  get_quiz,
  get_quizzes,
  get_choices,
  update_exam,
  update_quiz,
  delete_exam,
  delete_quiz,
  delete_quizzes,
  delete_choices,
  delete_choices_by_exam_id,
  count_exams,
  count_quizzes,
} from '../engines/dbfunc';

//################################# DECLARATION #################################
const THIS_FILENAME = 'exam.ts';

//################################# FUNCTION #################################


//################################# ROUTE #################################
const router: Router = express.Router();

/* define the HOME route */
router.get('/', (req: Request, res: Response) => {
  res.send('This is -Examination- API endpoint.');
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
   *      examcode: string,
   *      module_id: number,
   *      lesson_id: number,
   *      maxscore: number,
   *      examminute: number,
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
  let examcode = req.body.examcode;
  let module_id = req.body.module_id;
  let lesson_id = req.body.lesson_id;
  let maxscore = req.body.maxscore;
  let examminute = req.body.examminute;
  let title = req.body.title;
  let caption = req.body.caption;
  let descr = req.body.descr;
  let coverid = req.body.coverid;
  let maturityrating = req.body.maturityrating;
  let tags = req.body.tags;
  if (!(isData(examcode) && isData(title) && isData(maturityrating))) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  examcode = xString(examcode);
  module_id = xNumber(module_id);
  lesson_id = xNumber(lesson_id);
  maxscore = xNumber(maxscore);
  examminute = xNumber(examminute);
  title = xString(title);
  caption = xString(caption);
  descr = xString(descr);
  coverid = xString(coverid);
  maturityrating = xNumber(maturityrating);
  tags = xString(tags);
  const id = await add_exam(examcode, module_id, lesson_id, maxscore, examminute, title, caption, descr, coverid, maturityrating, tags);
  if ((id == K.SYS_INTERNAL_PROCESS_ERROR) || (!id)) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- Event Log
  const logdetail = JSON.stringify({
    id: id,
  });
  await add_log_user(userid, K_log_incident.EXAM_ADD, logdetail);
  // -- Done
  sendObj(1, 'ok', [], res);
});

/* define the Create-Quiz-One route */
router.post('/quiz', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      exam_id: number,
   *      quizno: number,
   *      quizminute: number,
   *      question: string,
   *      contentid: string,
   *      mediaid: string,
   *      choices: [
   *        {
   *          answer: string,
   *          choiceno: number,
   *          choicescore: number,
   *          becorrect: number,
   *          mediaid: string,
   *          feedbackid: string
   *        },
   *        ...
   *      ]
   *    }
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: []
   *    }
   */
  const userid = xString(res.locals.userid);
  let exam_id = req.body.exam_id;
  let quizno = req.body.quizno;
  let quizminute = req.body.quizminute;
  let question = req.body.question;
  let contentid = req.body.contentid;
  let mediaid = req.body.mediaid;
  let choices = req.body.choices;
  if (!(isData(exam_id) && isData(quizno) && isData(question) && Array.isArray(choices))) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  if (choices.length == 0) {
    sendObj(0, 'No choice data', [], res);
    return;
  }
  exam_id = xNumber(exam_id);
  quizno = xNumber(quizno);
  quizminute = xNumber(quizminute);
  question = xString(question);
  contentid = xString(contentid);
  mediaid = xString(mediaid);
  let rowno = 0;
  for (const choice of choices) {
    rowno++;
    if (!(isData(choice.answer) && isData(choice.becorrect))) {
      sendObj(3, 'Insufficient required fields', [{
        RowNo: rowno,
      }], res);
      return;
    }
  }
  // -- table: quizzes
  const id = await add_quiz(exam_id, quizno, quizminute, question, contentid, mediaid);
  if ((id == K.SYS_INTERNAL_PROCESS_ERROR) || (!id)) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- table: choices
  rowno = 0;
  for (const choice of choices) {
    rowno++;
    const answer = xString(choice.answer);
    const choiceno = xNumber(choice.choiceno);
    const choicescore = xNumber(choice.choicescore);
    const becorrect = xNumber(choice.becorrect);
    const mediaid = xString(choice.mediaid);
    const feedbackid = xString(choice.feedbackid);
    const choice_id = await add_choice(id, answer, choiceno, choicescore, becorrect, mediaid, feedbackid);
    if ((choice_id == K.SYS_INTERNAL_PROCESS_ERROR) || (!choice_id)) {
      sendObj(2, 'Internal process error', [{
        RowNo: rowno,
        Step: 'add choice',
      }], res);
      return;
    }
  }
  // -- Event Log
  const logdetail = JSON.stringify({
    id: id,
  });
  await add_log_user(userid, K_log_incident.QUIZ_ADD, logdetail);
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
   *          examid: "a303e760-db75-4692-a2e4-d2dad892f5f9",
   *          examcode: "EXAM-0001",
   *          ...
   *        }
   *      ]
   *    }
   */
  const id = xNumber(req.params.id);
  const exams = await get_exam(id);
  if (exams == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  if (exams.length == 0) {
    sendObj(2, 'Internal process error', [], res)
    return;
  }
  sendObj(1, 'ok', exams, res);
});

/* define the Read-Quiz-One route */
router.get('/quiz/id/:id', async (req: Request, res: Response) => {
  /**
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: [
   *        {
   *          quizno: "1",
   *          question: "What is the capital of Thailand?",
   *          ...
   *          choices: [
   *            {
   *              choiceno: "1",
   *              answer: "Bangkok",
   *              ...
   *            },
   *            ...
   *          ]
   *        }
   *      ]
   *    }
   */
  const id = xNumber(req.params.id);
  const quizzes = await get_quiz(id);
  if (quizzes.length == 0) {
    sendObj(2, 'Internal process error', [], res)
    return;
  }
  const choices = await get_choices(id);
  if (choices == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  quizzes[0].choices = choices;
  sendObj(1, 'ok', quizzes, res);
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
   *      examcode: string,
   *      module_id: number,
   *      lesson_id: number,
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
   *          examid: "a303e760-db75-4692-a2e4-d2dad892f5f9",
   *          examcode: "EXAM-0001",
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
  const examcode = xString(req.body.examcode);
  const module_id = req.body.module_id;
  const lesson_id = req.body.lesson_id;
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
  const exams = await get_exams(belocked, becancelled, docstatus, examcode, module_id, lesson_id, title, caption, descr, maturityrating, tags, {
    limit: limit,
    page: page,
    sort: sort,
  });
  if (exams == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  sendObj(1, 'ok', exams, res);
});

/* define the Read-Quiz-Filter route */
router.post('/quiz/filter', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      limit: number,
   *      page: number, // 1,2,...
   *      sort: string, // "asc", "desc" ; default = ""
   *      belocked: any,
   *      becancelled: any,
   *      docstatus: any,
   *      exam_id: number,
   *      question: string
   *    }
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: [
   *        {
   *          id: 1,
   *          quizno: 1,
   *          question: "What is the capital of Thailand?",
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
  const exam_id = xNumber(req.body.exam_id);
  const question = xString(req.body.question);
  if (!(limit && page && exam_id)) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  if ((limit <= 0) || (page <= 0)) {
    sendObj(5, 'Incorrect pagination fields', [], res);
    return;
  }
  const quizzes = await get_quizzes(belocked, becancelled, docstatus, exam_id, question, {
    limit: limit,
    page: page,
    sort: sort,
  });
  if (quizzes == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  sendObj(1, 'ok', quizzes, res);
});

/* define the Read-Count route */
router.post('/count', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      belocked: any,
   *      becancelled: any,
   *      docstatus: any,
   *      examcode: string,
   *      module_id: number,
   *      lesson_id: number,
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
  const examcode = xString(req.body.examcode);
  const module_id = req.body.module_id;
  const lesson_id = req.body.lesson_id;
  const title = xString(req.body.title);
  const caption = xString(req.body.caption);
  const descr = xString(req.body.descr);
  const maturityrating = req.body.maturityrating;
  const tags = xString(req.body.tags);
  const RecordCount = await count_exams(belocked, becancelled, docstatus, examcode, module_id, lesson_id, title, caption, descr, maturityrating, tags);
  if (RecordCount == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  sendObj(1, 'ok', [{ RecordCount: RecordCount }], res);
});

/* define the Read-Quiz-Count route */
router.post('/quiz/count', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      belocked: any,
   *      becancelled: any,
   *      docstatus: any,
   *      exam_id: number,
   *      question: string
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
  const exam_id = xNumber(req.body.exam_id);
  const question = xString(req.body.question);
  if (!(exam_id)) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  const RecordCount = await count_quizzes(belocked, becancelled, docstatus, exam_id, question);
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
   *      examcode: string,
   *      module_id: number,
   *      lesson_id: number,
   *      maxscore: number,
   *      examminute: number,
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
  let examcode = req.body.examcode;
  let module_id = req.body.module_id;
  let lesson_id = req.body.lesson_id;
  let maxscore = req.body.maxscore;
  let examminute = req.body.examminute;
  let title = req.body.title;
  let caption = req.body.caption;
  let descr = req.body.descr;
  let coverid = req.body.coverid;
  let maturityrating = req.body.maturityrating;
  let tags = req.body.tags;
  if (!(isData(examcode) && isData(title) && isData(maturityrating))) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  examcode = xString(examcode);
  module_id = xNumber(module_id);
  lesson_id = xNumber(lesson_id);
  maxscore = xNumber(maxscore);
  examminute = xNumber(examminute);
  title = xString(title);
  caption = xString(caption);
  descr = xString(descr);
  coverid = xString(coverid);
  maturityrating = xNumber(maturityrating);
  tags = xString(tags);
  let affectedRows = await update_exam(id, examcode, module_id, lesson_id, maxscore, examminute, title, caption, descr, coverid, maturityrating, tags);
  if ((affectedRows == K.SYS_INTERNAL_PROCESS_ERROR) || (!affectedRows)) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- Event Log
  const logdetail = JSON.stringify({
    id: id,
  });
  await add_log_user(userid, K_log_incident.EXAM_EDIT, logdetail);
  // -- Done
  sendObj(1, 'ok', [], res);
});

/* define the Update-Quiz-One route */
router.put('/quiz/id/:id', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      exam_id: number,
   *      quizno: number,
   *      quizminute: number,
   *      question: string,
   *      contentid: string,
   *      mediaid: string,
   *      choices: [
   *        {
   *          answer: string,
   *          choiceno: number,
   *          choicescore: number,
   *          becorrect: number,
   *          mediaid: string,
   *          feedbackid: string
   *        },
   *        ...
   *      ]
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
  let exam_id = req.body.exam_id;
  let quizno = req.body.quizno;
  let quizminute = req.body.quizminute;
  let question = req.body.question;
  let contentid = req.body.contentid;
  let mediaid = req.body.mediaid;
  let choices = req.body.choices;
  if (!(isData(exam_id) && isData(quizno) && isData(question) && Array.isArray(choices))) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  if (choices.length == 0) {
    sendObj(0, 'No choice data', [], res);
    return;
  }
  exam_id = xNumber(exam_id);
  quizno = xNumber(quizno);
  quizminute = xNumber(quizminute);
  question = xString(question);
  contentid = xString(contentid);
  mediaid = xString(mediaid);
  let rowno = 0;
  for (const choice of choices) {
    rowno++;
    if (!(isData(choice.answer) && isData(choice.becorrect))) {
      sendObj(3, 'Insufficient required fields', [{
        RowNo: rowno,
      }], res);
      return;
    }
  }
  // -- table: quizzes
  let affectedRows = await update_quiz(id, exam_id, quizno, quizminute, question, contentid, mediaid);
  if ((affectedRows == K.SYS_INTERNAL_PROCESS_ERROR) || (!affectedRows)) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- table: choices
  affectedRows = await delete_choices(id);
  if (affectedRows == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  rowno = 0;
  for (const choice of choices) {
    rowno++;
    const answer = xString(choice.answer);
    const choiceno = xNumber(choice.choiceno);
    const choicescore = xNumber(choice.choicescore);
    const becorrect = xNumber(choice.becorrect);
    const mediaid = xString(choice.mediaid);
    const feedbackid = xString(choice.feedbackid);
    const choice_id = await add_choice(id, answer, choiceno, choicescore, becorrect, mediaid, feedbackid);
    if ((choice_id == K.SYS_INTERNAL_PROCESS_ERROR) || (!choice_id)) {
      sendObj(2, 'Internal process error', [{
        RowNo: rowno,
        Step: 'add choice',
      }], res);
      return;
    }
  }
  // -- Event Log
  const logdetail = JSON.stringify({
    id: id,
  });
  await add_log_user(userid, K_log_incident.QUIZ_EDIT, logdetail);
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
  // -- table: choices
  let affectedRows = await delete_choices_by_exam_id(id);
  if (affectedRows == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- table: quizzes
  affectedRows = await delete_quizzes(id);
  if (affectedRows == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- table: exams
  affectedRows = await delete_exam(id);
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
  await add_log_user(userid, K_log_incident.EXAM_DEL, logdetail);
  // -- Done
  sendObj(1, 'ok', [], res);
});

/* define the Delete-Quiz-One route */
router.delete('/quiz/id/:id', async (req: Request, res: Response) => {
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
  // -- table: choices
  let affectedRows = await delete_choices(id);
  if (affectedRows == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- table: quizzes
  affectedRows = await delete_quiz(id);
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
  await add_log_user(userid, K_log_incident.QUIZ_DEL, logdetail);
  // -- Done
  sendObj(1, 'ok', [], res);
});

export default router;