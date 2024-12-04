//################################# INCLUDE #################################
//---- System Modules ----
// import crypto from 'crypto';

//---- Application Modules ----
import K from './constant';
import dbconnect from './db_oper';
import { xString, xNumber, isData, incident } from './originutil';

//################################# DECLARATION #################################
const THIS_FILENAME = 'dbfunc.ts';

const SCHEMA_DATA = 'caige_data';
const SCHEMA_OPER = 'caige_oper';

//################################# FUNCTION #################################
async function add_assessment(
  userid: string,
  examid: string
) {
  let id = 0;
  try {
    const sql = `
      INSERT INTO assessments
        (userid, examid)
        VALUES
        (?,?)
        RETURNING id;
    `;
    const result = await dbconnect.execute(sql, [
      userid,
      examid
    ]); 
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':add_assessment', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return id;
}

async function get_assessments(
  datefrom: string,
  dateto: string,
  finishedfrom: string,
  finishedto: string,
  userid: string,
  examcode: string,
  module_id: any,
  lesson_id: any,
  filter: any
) {
  const limit = xNumber(filter.limit);
  const page = xNumber(filter.page);
  const sort = xString(filter.sort);
  // Validation
  if ((limit <= 0) || (page <= 0)) {
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  let p = page - 1;
  if (p <= 0) { p = 0; }
  const offset = p * limit;
  let sortclause = "ASC";
  if (sort.toLowerCase() == 'desc') {
    sortclause = "DESC";
  }
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (datefrom) {
    whereclause += " AND a.created_at >= ?";
    argumentarr.push(datefrom.trim());
  }
  if (dateto) {
    whereclause += " AND a.created_at < ?";
    argumentarr.push(dateto.trim());
  }
  if (finishedfrom) {
    whereclause += " AND a.finished_at >= ?";
    argumentarr.push(finishedfrom.trim());
  }
  if (finishedto) {
    whereclause += " AND a.finished_at < ?";
    argumentarr.push(finishedto.trim());
  }
  if (userid) {
    whereclause += " AND a.userid = ?";
    argumentarr.push(userid.trim());
  }
  if (examcode) {
    whereclause += " AND e.examcode LIKE ?";
    argumentarr.push('%'+examcode.trim()+'%');
  }
  if (isData(module_id)) {
    whereclause += " AND e.module_id = ?";
    argumentarr.push(xNumber(module_id));
  }
  if (isData(lesson_id)) {
    whereclause += " AND e.lesson_id = ?";
    argumentarr.push(xNumber(lesson_id));
  }
  argumentarr.push(xNumber(limit));
  argumentarr.push(xNumber(offset));
  // Execute SQL
  let records = [];
  try {
    const sql = `
      SELECT a.id, a.created_at, a.updated_at, a.finished_at
        , a.userid, a.examid, e.examcode, e.module_id, e.lesson_id
        , e.maxscore, e.examminute, e.title
        , a.finishscore, a.finishminute
        FROM ${SCHEMA_OPER}.assessments a
        LEFT JOIN ${SCHEMA_DATA}.exams e ON e.examid = a.examid
        ${whereclause}
        ORDER BY a.created_at ${sortclause}, a.id ${sortclause}
        LIMIT ? OFFSET ?;
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_assessments', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function update_assessment(
  id: number,
  examid: string,
  finishscore: number,
  finishminute: number
) {
  let affectedRows = 0;
  try {
    const sql = `
      UPDATE assessments
        SET finished_at = CURRENT_TIMESTAMP
          , finishscore = ?
          , finishminute = ?
        WHERE id = ?
          AND examid = ?;
    `;
    const result = await dbconnect.execute(sql, [
      finishscore,
      finishminute,
      id,
      examid
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':update_assessment', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function count_assessments(
  datefrom: string,
  dateto: string,
  finishedfrom: string,
  finishedto: string,
  userid: string,
  examcode: string,
  module_id: any,
  lesson_id: any,
) {
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (datefrom) {
    whereclause += " AND a.created_at >= ?";
    argumentarr.push(datefrom.trim());
  }
  if (dateto) {
    whereclause += " AND a.created_at < ?";
    argumentarr.push(dateto.trim());
  }
  if (finishedfrom) {
    whereclause += " AND a.finished_at >= ?";
    argumentarr.push(finishedfrom.trim());
  }
  if (finishedto) {
    whereclause += " AND a.finished_at < ?";
    argumentarr.push(finishedto.trim());
  }
  if (userid) {
    whereclause += " AND a.userid = ?";
    argumentarr.push(userid.trim());
  }
  if (examcode) {
    whereclause += " AND e.examcode LIKE ?";
    argumentarr.push('%'+examcode.trim()+'%');
  }
  if (isData(module_id)) {
    whereclause += " AND e.module_id = ?";
    argumentarr.push(xNumber(module_id));
  }
  if (isData(lesson_id)) {
    whereclause += " AND e.lesson_id = ?";
    argumentarr.push(xNumber(lesson_id));
  }
  // Execute SQL
  let RecordCount = 0;
  try {
    const sql = `
      SELECT COUNT(a.id) AS RecordCount
        FROM ${SCHEMA_OPER}.assessments a
        LEFT JOIN ${SCHEMA_DATA}.exams e ON e.examid = a.examid
        ${whereclause};
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      RecordCount = xNumber(result[0].RecordCount);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':count_assessments', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return RecordCount;
}

async function start_exam(
  examcode: string,
  module_id: any,
  lesson_id: any
) {
  // Prepare SQL
  let whereclause = `
    WHERE belocked = 0
      AND becancelled = 0
  `;
  let argumentarr = [];
  if (examcode) {
    whereclause += " AND examcode = ?";
    argumentarr.push(examcode.trim());
  }
  if (isData(module_id)) {
    whereclause += " AND module_id = ?";
    argumentarr.push(xNumber(module_id));
  }
  if (isData(lesson_id)) {
    whereclause += " AND lesson_id = ?";
    argumentarr.push(xNumber(lesson_id));
  }
  // Execute SQL
  let records = [];
  try {
    const sql = `
      SELECT id, examid, examcode, module_id, lesson_id, maxscore, examminute
        , title, caption, descr, coverid
        FROM ${SCHEMA_DATA}.exams
        ${whereclause}
        ORDER BY id DESC
        LIMIT 1;
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':start_exam', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function start_quizzes(exam_id: number) {
  // Prepare SQL
  let whereclause = `
  WHERE belocked = 0
    AND becancelled = 0
    AND exam_id = ?
`;
  let argumentarr = [];
  argumentarr.push(exam_id);
  // Execute SQL
  let records = [];
  try {
    const sql = `
      SELECT id, quizno, quizminute, question
        , contentid, mediaid
        FROM ${SCHEMA_DATA}.quizzes
        ${whereclause}
        ORDER BY quizno, id;
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':start_quizzes', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function start_choices(quiz_id: number) {
  let records = [];
  try {
    const sql = `
      SELECT id, answer, choiceno, mediaid
        FROM ${SCHEMA_DATA}.choices
        WHERE quiz_id = ?
        ORDER BY RAND();
    `;
    const result = await dbconnect.execute(sql, [
      quiz_id
    ]);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':start_choices', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function check_choice(
  examid: string,
  quiz_id: number, 
  choice_id: number
) {
  let records = [];
  try {
    const sql = `
      SELECT c.id, c.choicescore, c.becorrect, c.feedbackid
        FROM ${SCHEMA_DATA}.choices c
        INNER JOIN ${SCHEMA_DATA}.quizzes q ON q.id = c.quiz_id
        INNER JOIN ${SCHEMA_DATA}.exams e ON e.id = q.exam_id
        WHERE c.id = ?
          AND c.quiz_id = ?
          AND e.examid = ?;
    `;
    const result = await dbconnect.execute(sql, [
      choice_id,
      quiz_id,
      examid
    ]);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':check_choice', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

export {
  add_assessment,
  get_assessments,
  update_assessment,
  count_assessments,
  start_exam,
  start_quizzes,
  start_choices,
  check_choice,
}