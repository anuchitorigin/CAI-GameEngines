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
  add_assessment,
  get_assessments,
  update_assessment,
  count_assessments,
  start_exam,
  start_quizzes,
  start_choices,
  check_choice,
} from '../engines/dbfunc';

//################################# DECLARATION #################################
const THIS_FILENAME = 'assessment.ts';

//################################# FUNCTION #################################


//################################# ROUTE #################################
const router: Router = express.Router();

/* define the HOME route */
router.get('/', (req: Request, res: Response) => {
  res.send('This is -Assessment- API endpoint.');
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
   *      lesson_id: number
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
   *          quizzes: [
   *            {
   *              id: 1,
   *              quizno: 1,
   *              question: "What is the capital of Thailand?",
   *              ...
   *              choices: [
   *                {
   *                  id: 1,
   *                  choiceno: 1,
   *                  answer: "Bangkok",
   *                },
   *                ...
   *              ]
   *            },
   *            ...  
   *          ]
   *        },
   *        ...
   *      ]
   *    }
   */
  const userid = xString(res.locals.userid);
  const examcode = xString(req.body.examcode);
  const module_id = req.body.module_id;
  const lesson_id = req.body.lesson_id;
  // -- Get Exam
  const exams = await start_exam(examcode, module_id, lesson_id);
  if (exams == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  const exam_id = exams[0].id;
  const examid = exams[0].examid;
  // -- Get Quizzes
  const quizzes = await start_quizzes(exam_id);
  if (quizzes == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  let id = 0;
  if (quizzes.length > 0) {
    // -- Get Choices
    for (const quiz of quizzes) {
      let quiz_id = xNumber(quiz.id);
      const choices = await start_choices(quiz_id);
      if (choices == K.SYS_INTERNAL_PROCESS_ERROR) {
        sendObj(2, 'Internal process error', [], res);
        return;
      }
      quiz.choices = choices;
    }
    // -- Add Assessment
    id = await add_assessment(userid, examid);
    if ((id == K.SYS_INTERNAL_PROCESS_ERROR) || (!id)) {
      sendObj(2, 'Internal process error', [], res);
      return;
    }
  }
  exams[0].assessment_id = id;
  exams[0].quizzes = quizzes;
  // -- Event Log
  const logdetail = JSON.stringify({
    examcode: examcode,
    module_id: module_id,
    lesson_id: lesson_id,
    exam_id: exam_id,
    id: id,
  });
  await add_log_user(userid, K_log_incident.ASSESSMENT_ADD, logdetail);
  // -- Done
  sendObj(1, 'ok', exams, res);
});

/* define the Read-Filter route */
router.post('/filter', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      limit: number,
   *      page: number, // 1,2,...
   *      sort: string, // "asc", "desc" ; default = ""
   *      datefrom: string, // start from (>=) '2022-06-06 16:00:00'
   *      dateto: string, // to but not include (<) '2022-06-07 16:00:00'
   *      finishedfrom: string, // start from (>=) '2022-06-06 16:00:00'
   *      finishedto: string, // to but not include (<) '2022-06-07 16:00:00'
   *      userid: string,
   *      examcode: string,
   *      module_id: number,
   *      lesson_id: number
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
  const datefrom = xString(req.body.datefrom); 
  const dateto = xString(req.body.dateto); 
  const finishedfrom = xString(req.body.finishedfrom);
  const finishedto = xString(req.body.finishedto);
  const userid = xString(req.body.userid);
  const examcode = xString(req.body.examcode);
  const module_id = req.body.module_id;
  const lesson_id = req.body.lesson_id;
  if (!(limit && page)) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  if ((limit <= 0) || (page <= 0)) {
    sendObj(5, 'Incorrect pagination fields', [], res);
    return;
  }
  const assessments = await get_assessments(datefrom, dateto, finishedfrom, finishedto, userid, examcode, module_id, lesson_id, {
    limit: limit,
    page: page,
    sort: sort,
  });
  if (assessments == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  sendObj(1, 'ok', assessments, res);
});

/* define the Read-Count route */
router.post('/count', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      datefrom: string, // start from (>=) '2022-06-06 16:00:00'
   *      dateto: string, // to but not include (<) '2022-06-07 16:00:00'
   *      finishedfrom: string, // start from (>=) '2022-06-06 16:00:00'
   *      finishedto: string, // to but not include (<) '2022-06-07 16:00:00'
   *      userid: string,
   *      examcode: string,
   *      module_id: number,
   *      lesson_id: number
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
  const datefrom = xString(req.body.datefrom); 
  const dateto = xString(req.body.dateto); 
  const finishedfrom = xString(req.body.finishedfrom);
  const finishedto = xString(req.body.finishedto);
  const userid = xString(req.body.userid);
  const examcode = xString(req.body.examcode);
  const module_id = req.body.module_id;
  const lesson_id = req.body.lesson_id;
  const RecordCount = await count_assessments(datefrom, dateto, finishedfrom, finishedto, userid, examcode, module_id, lesson_id);
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
   *      examid: string,
   *      finishminute: number,
   *      quizzes: [
   *        {
   *          id: 1,
   *          choice_id: 1
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
  let examid = req.body.examid;
  let finishminute = req.body.finishminute;
  let quizzes = req.body.quizzes;
  if (!(isData(examid) && isData(finishminute) && Array.isArray(quizzes))) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  if (quizzes.length == 0) {
    sendObj(0, 'No quiz data', [], res);
    return;
  }
  examid = xString(examid);
  finishminute = xNumber(finishminute);
  let finishscore = 0;
  // -- Check Choices
  let rowno = 0;
  for (const quiz of quizzes) {
    rowno++;
    if (!(isData(quiz.id) && isData(quiz.choice_id))) {
      sendObj(3, 'Insufficient required fields', [{
        RowNo: rowno,
      }], res);
      return;
    }
    const quiz_id = xNumber(quiz.id);
    const choice_id = xNumber(quiz.choice_id);
    const choices = await check_choice(examid, quiz_id, choice_id);
    if (choices == K.SYS_INTERNAL_PROCESS_ERROR) {
      sendObj(2, 'Internal process error', [], res);
      return;
    }
    if (choices.length == 0) {
      sendObj(2, 'Internal process error', [], res);
      return;
    }
    const choicescore = xNumber(choices[0].choicescore);
    const becorrect = xNumber(choices[0].becorrect);
    if (becorrect) {
      finishscore += choicescore;
    }
  }
  // -- Update Assessment
  let affectedRows = await update_assessment(id, examid, finishscore, finishminute);
  if ((affectedRows == K.SYS_INTERNAL_PROCESS_ERROR) || (!affectedRows)) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- Event Log
  const logdetail = JSON.stringify({
    id: id,
    affectedRows: affectedRows,
  });
  await add_log_user(userid, K_log_incident.ASSESSMENT_EDIT, logdetail);
  // -- Done
  sendObj(1, 'ok', [], res);
});

/* define the Check-Choice route */
router.post('/check/choice', async (req: Request, res: Response) => {
  /**
   *  Request:-
   *    {
   *      examid: string,
   *      quiz_id: number,
   *      choice_id: number
   *    }
   *  Response:-
   *    {
   *      status: 1,
   *      message: "ok",
   *      result: []
   *    }
   */
  const userid = xString(res.locals.userid);
  let examid = req.body.examid;
  let quiz_id = req.body.quiz_id;
  let choice_id = req.body.choice_id;
  if (!(isData(quiz_id) && isData(choice_id))) {
    sendObj(3, 'Insufficient required fields', [], res);
    return;
  }
  examid = xString(examid);
  quiz_id = xNumber(quiz_id);
  choice_id = xNumber(choice_id);
  const choices = await check_choice(examid, quiz_id, choice_id);
  if (choices == K.SYS_INTERNAL_PROCESS_ERROR) {
    sendObj(2, 'Internal process error', [], res);
    return;
  }
  // -- Event Log
  const logdetail = JSON.stringify({
    quiz_id: quiz_id,
    choice_id: choice_id,
    found: choices.length,
  });
  await add_log_user(userid, K_log_incident.ASSESSMENT_CHECK, logdetail);
  // -- Done
  sendObj(1, 'ok', choices, res);
});

export default router;