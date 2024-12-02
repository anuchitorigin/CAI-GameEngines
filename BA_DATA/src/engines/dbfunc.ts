//################################# INCLUDE #################################
//---- System Modules ----
import crypto from 'crypto';

//---- Application Modules ----
import K from './constant';
import dbconnect from './db_data';
import { xString, xNumber, toArray, isData, incident } from './originutil';

//################################# DECLARATION #################################
const THIS_FILENAME = 'dbfunc.ts';

//################################# FUNCTION #################################
async function add_module(
  modulecode: string,
  title: string,
  caption: string,
  descr: string,
  coverid: string,
  maturityrating: number,
  tags: string
) {
  const moduleid = crypto.randomUUID();
  let id = 0;
  try {
    const sql = `
      INSERT INTO modules
        (moduleid, modulecode, title, caption, descr, coverid, maturityrating, tags)
        VALUES
        (?,?,?,?,?,?,?,?)
        RETURNING id;
    `;
    const result = await dbconnect.execute(sql, [
      moduleid, 
      modulecode, 
      title, 
      caption, 
      descr, 
      coverid, 
      maturityrating, 
      tags
    ]); 
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':add_module', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return id;
}

async function add_lesson(
  lessoncode: string,
  module_id: number,
  lessonno: number,
  title: string,
  descr: string,
  coverid: string,
  contentid: string,
  mediaid: string,
  tags: string
) {
  const lessonid = crypto.randomUUID();
  let id = 0;
  try {
    const sql = `
      INSERT INTO lessons
        (lessonid, lessoncode, module_id, lessonno, title, descr, coverid, contentid, mediaid, tags)
        VALUES
        (?,?,?,?,?,?,?,?,?,?)
        RETURNING id;
    `;
    const result = await dbconnect.execute(sql, [
      lessonid, 
      lessoncode, 
      module_id, 
      lessonno, 
      title, 
      descr, 
      coverid, 
      contentid, 
      mediaid, 
      tags
    ]); 
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':add_lesson', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return id;
}

async function add_exam(
  examcode: string,
  module_id: number,
  lesson_id: number,
  maxscore: number,
  examminute: number,
  title: string,
  caption: string,
  descr: string,
  coverid: string,
  maturityrating: number,
  tags: string
) {
  const examid = crypto.randomUUID();
  let id = 0;
  try {
    const sql = `
      INSERT INTO exams
        (examid, examcode, module_id, lesson_id, maxscore, examminute, title, caption, descr, coverid, maturityrating, tags)
        VALUES
        (?,?,?,?,?,?,?,?,?,?,?,?)
        RETURNING id;
    `;
    const result = await dbconnect.execute(sql, [
      examid, 
      examcode, 
      module_id, 
      lesson_id, 
      maxscore, 
      examminute, 
      title, 
      caption, 
      descr, 
      coverid, 
      maturityrating, 
      tags
    ]); 
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':add_exam', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return id;
}

async function add_quiz(
  exam_id: number,
  quizno: number,
  quizminute: number,
  question: string,
  contentid: string,
  mediaid: string
) {
  let id = 0;
  try {
    const sql = `
      INSERT INTO quizzes
        (exam_id, quizno, quizminute, question, contentid, mediaid)
        VALUES
        (?,?,?,?,?,?)
        RETURNING id;
    `;
    const result = await dbconnect.execute(sql, [
      exam_id, 
      quizno, 
      quizminute, 
      question, 
      contentid, 
      mediaid
    ]); 
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':add_quiz', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return id;
}

async function add_choice(
  quiz_id: number,
  answer: string,
  choiceno: number,
  choicescore: number,
  becorrect: number,
  mediaid: string,
  feedbackid: string
) {
  let id = 0;
  try {
    const sql = `
      INSERT INTO choices
        (quiz_id, answer, choiceno, choicescore, becorrect, mediaid, feedbackid)
        VALUES
        (?,?,?,?,?,?,?)
        RETURNING id;
    `;
    const result = await dbconnect.execute(sql, [
      quiz_id, 
      answer, 
      choiceno, 
      choicescore, 
      becorrect, 
      mediaid, 
      feedbackid
    ]); 
    if (result.length > 0) {
      id = xNumber(result[0].id);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':add_choice', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return id;
}

async function get_sysvar(id: number) {
  let records = [];
  try {
    const sql = `
      SELECT id, varid, varname, descr, varvalue
        FROM sysvars
        WHERE id = ?
        ORDER BY id DESC
        LIMIT 1;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_sysvar', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function get_sysvars() {
  let records = [];
  try {
    const sql = `
      SELECT id, varid, varname, descr, varvalue
        FROM sysvars
        ORDER BY id;
    `;
    const result = await dbconnect.execute(sql, []);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_sysvars', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function get_module(id: number) {
  let records = [];
  try {
    const sql = `
      SELECT id, created_at, updated_at, belocked, becancelled, docstatus
        , moduleid, modulecode, title, caption, descr, coverid
        , maturityrating, tags, released_at
        FROM modules
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_module', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;  
}

async function get_modules(
  belocked: any,
  becancelled: any,
  docstatus: any,
  modulecode: string,
  title: string,
  caption: string,
  descr: string,
  maturityrating: any,
  tags: any,
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
  if (isData(belocked)) {
    whereclause += " AND belocked = ?";
    argumentarr.push(xNumber(belocked));
  }
  if (isData(becancelled)) {
    whereclause += " AND becancelled = ?";
    argumentarr.push(xNumber(becancelled));
  }
  if (isData(docstatus)) {
    whereclause += " AND docstatus = ?";
    argumentarr.push(xNumber(docstatus));
  }
  if (modulecode) {
    whereclause += " AND modulecode LIKE ?";
    argumentarr.push('%'+modulecode.trim()+'%');
  }
  if (title) {
    whereclause += " AND title LIKE ?";
    argumentarr.push('%'+title.trim()+'%');
  }
  if (caption) {
    whereclause += " AND caption LIKE ?";
    argumentarr.push('%'+caption.trim()+'%');
  }
  if (descr) {
    whereclause += " AND descr LIKE ?";
    argumentarr.push('%'+descr.trim()+'%');
  }
  if (isData(maturityrating)) {
    whereclause += " AND maturityrating = ?";
    argumentarr.push(xNumber(maturityrating));
  }
  if (isData(tags)) {
    const tagarr = toArray(tags);
    if (tagarr.length > 0) {
      whereclause += " AND (";
      for (let i = 0; i < tagarr.length; i++) {
        if (i > 0) {
          whereclause += " OR";
        }
        whereclause += " LOWER(tags) LIKE LOWER(?)";
        argumentarr.push('%"'+tagarr[i]+'"%');
      }
      whereclause += ")";
    }
  }
  argumentarr.push(xNumber(limit));
  argumentarr.push(xNumber(offset));
  // Execute SQL
  let records = [];
  try {
    const sql = `
      SELECT id, created_at, updated_at, belocked, becancelled, docstatus
        , moduleid, modulecode, title, caption, descr, coverid
        , maturityrating, tags, released_at
        FROM modules
        ${whereclause}
        ORDER BY modulecode ${sortclause}
        LIMIT ? OFFSET ?;
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_modules', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function get_lesson(id: number) {
  let records = [];
  try {
    const sql = `
      SELECT id, created_at, updated_at, belocked, becancelled, docstatus
        , lessonid, lessoncode, module_id, lessonno, title, descr, coverid
        , contentid, mediaid, tags, released_at
        FROM lessons
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_lesson', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;  
}

async function get_lessons(
  module_id: number,
  lessoncode: string,
  title: string,
  descr: string,
  tags: string,
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
  if (isData(module_id)) {
    whereclause += " AND module_id = ?";
    argumentarr.push(xNumber(module_id));
  }
  if (lessoncode) {
    whereclause += " AND lessoncode LIKE ?";
    argumentarr.push('%'+lessoncode.trim()+'%');
  }
  if (title) {
    whereclause += " AND title LIKE ?";
    argumentarr.push('%'+title.trim()+'%');
  }
  if (descr) {
    whereclause += " AND descr LIKE ?";
    argumentarr.push('%'+descr.trim()+'%');
  }
  if (isData(tags)) {
    const tagarr = toArray(tags);
    if (tagarr.length > 0) {
      whereclause += " AND (";
      for (let i = 0; i < tagarr.length; i++) {
        if (i > 0) {
          whereclause += " OR";
        }
        whereclause += " LOWER(tags) LIKE LOWER(?)";
        argumentarr.push('%"'+tagarr[i]+'"%');
      }
      whereclause += ")";
    }
  }
  argumentarr.push(xNumber(limit));
  argumentarr.push(xNumber(offset));
  // Execute SQL
  let records = [];
  try {
    const sql = `
      SELECT id, created_at, updated_at, belocked, becancelled, docstatus
        , lessonid, lessoncode, module_id, lessonno, title, descr, coverid
        , contentid, mediaid, tags, released_at
        FROM lessons
        ${whereclause}
        ORDER BY lessonno ${sortclause}, id
        LIMIT ? OFFSET ?;
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_lessons', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function get_exam(id: number) {
  let records = [];
  try {
    const sql = `
      SELECT id, created_at, updated_at, belocked, becancelled, docstatus
        , examid, examcode, module_id, lesson_id, maxscore, examminute  
        , title, caption, descr, coverid
        , maturityrating, tags, released_at
        FROM exams
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_exam', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;  
}

async function get_exams(
  belocked: any,
  becancelled: any,
  docstatus: any,
  examcode: string,
  module_id: any,
  lesson_id: any,
  title: string,
  caption: string,
  descr: string,
  maturityrating: any,
  tags: any,
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
  if (isData(belocked)) {
    whereclause += " AND belocked = ?";
    argumentarr.push(xNumber(belocked));
  }
  if (isData(becancelled)) {
    whereclause += " AND becancelled = ?";
    argumentarr.push(xNumber(becancelled));
  }
  if (isData(docstatus)) {
    whereclause += " AND docstatus = ?";
    argumentarr.push(xNumber(docstatus));
  }
  if (examcode) {
    whereclause += " AND examcode LIKE ?";
    argumentarr.push('%'+examcode.trim()+'%');
  }
  if (isData(module_id)) {
    whereclause += " AND module_id = ?";
    argumentarr.push(xNumber(module_id));
  }
  if (isData(lesson_id)) {
    whereclause += " AND lesson_id = ?";
    argumentarr.push(xNumber(lesson_id));
  }
  if (title) {
    whereclause += " AND title LIKE ?";
    argumentarr.push('%'+title.trim()+'%');
  }
  if (caption) {
    whereclause += " AND caption LIKE ?";
    argumentarr.push('%'+caption.trim()+'%');
  }
  if (descr) {
    whereclause += " AND descr LIKE ?";
    argumentarr.push('%'+descr.trim()+'%');
  }
  if (isData(maturityrating)) {
    whereclause += " AND maturityrating = ?";
    argumentarr.push(xNumber(maturityrating));
  }
  if (isData(tags)) {
    const tagarr = toArray(tags);
    if (tagarr.length > 0) {
      whereclause += " AND (";
      for (let i = 0; i < tagarr.length; i++) {
        if (i > 0) {
          whereclause += " OR";
        }
        whereclause += " LOWER(tags) LIKE LOWER(?)";
        argumentarr.push('%"'+tagarr[i]+'"%');
      }
      whereclause += ")";
    }
  }
  argumentarr.push(xNumber(limit));
  argumentarr.push(xNumber(offset));
  // Execute SQL
  let records = [];
  try {
    const sql = `
      SELECT id, created_at, updated_at, belocked, becancelled, docstatus
        , examid, examcode, module_id, lesson_id, maxscore, examminute  
        , title, caption, descr, coverid
        , maturityrating, tags, released_at
        FROM exams
        ${whereclause}
        ORDER BY examcode ${sortclause}
        LIMIT ? OFFSET ?;
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_exams', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function get_quiz(id: number) {
  let records = [];
  try {
    const sql = `
      SELECT id, created_at, updated_at, belocked, becancelled, docstatus
        , exam_id, quizno, quizminute, question
        , contentid, mediaid, released_at
        FROM quizzes
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_quiz', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;  
}

async function get_quizzes(
  belocked: any,
  becancelled: any,
  docstatus: any,
  exam_id: any,
  question: string,
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
  if (isData(belocked)) {
    whereclause += " AND belocked = ?";
    argumentarr.push(xNumber(belocked));
  }
  if (isData(becancelled)) {
    whereclause += " AND becancelled = ?";
    argumentarr.push(xNumber(becancelled));
  }
  if (isData(docstatus)) {
    whereclause += " AND docstatus = ?";
    argumentarr.push(xNumber(docstatus));
  }
  if (isData(exam_id)) {
    whereclause += " AND exam_id = ?";
    argumentarr.push(xNumber(exam_id));
  }
  if (question) {
    whereclause += " AND question LIKE ?";
    argumentarr.push('%'+question.trim()+'%');
  }
  argumentarr.push(xNumber(limit));
  argumentarr.push(xNumber(offset));
  // Execute SQL
  let records = [];
  try {
    const sql = `
      SELECT id, created_at, updated_at, belocked, becancelled, docstatus
        , exam_id, quizno, quizminute, question
        , contentid, mediaid, released_at
        FROM quizzes
        ${whereclause}
        ORDER BY quizno ${sortclause}, id
        LIMIT ? OFFSET ?;
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_quizzes', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function get_choices(quiz_id: number) {
  let records = [];
  try {
    const sql = `
      SELECT id, created_at, updated_at
        , quiz_id, answer, choiceno, choicescore, becorrect
        , mediaid, feedbackid
        FROM choices
        WHERE quiz_id = ?
        ORDER BY choiceno, id;
    `;
    const result = await dbconnect.execute(sql, [
      quiz_id
    ]);
    if (result.length > 0) {
      records = result;
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':get_choices', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return records;
}

async function update_sysvar(
  id: number,
  varname: string,
  descr: string, 
  varvalue: string
) {
  let affectedRows = 0;
  try {
    const sql = `
      UPDATE sysvars
        SET varname = ?
          , descr = ?
          , varvalue = ?
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      varname, 
      descr, 
      varvalue, 
      id
    ]); // ResultSetHeader { affectedRows: 1, insertId: 0, warningStatus: 0, changedRows: 1 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':update_sysvar', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function update_module(
  id: number,
  modulecode: string,
  title: string,
  caption: string,
  descr: string,
  coverid: string,
  maturityrating: number,
  tags: string
) {
  let affectedRows = 0;
  try {
    const sql = `
      UPDATE modules
        SET modulecode = ?
          , title = ?
          , caption = ?
          , descr = ?
          , coverid = ?
          , maturityrating = ?
          , tags = ?
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      modulecode, 
      title, 
      caption, 
      descr, 
      coverid, 
      maturityrating, 
      tags, 
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':update_module', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function update_lesson(
  id: number,
  lessoncode: string,
  module_id: number,
  lessonno: number,
  title: string,
  descr: string,
  coverid: string,
  contentid: string,
  mediaid: string,
  tags: string
) {
  let affectedRows = 0;
  try {
    const sql = `
      UPDATE lessons
        SET lessoncode = ?
          , module_id = ?
          , lessonno = ?
          , title = ?
          , descr = ?
          , coverid = ?
          , contentid = ?
          , mediaid = ?
          , tags = ?
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      lessoncode, 
      module_id, 
      lessonno, 
      title, 
      descr, 
      coverid, 
      contentid, 
      mediaid, 
      tags, 
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':update_lesson', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function update_exam(
  id: number,
  examcode: string,
  module_id: number,
  lesson_id: number,
  maxscore: number,
  examminute: number,
  title: string,
  caption: string,
  descr: string,
  coverid: string,
  maturityrating: number,
  tags: string
) {
  let affectedRows = 0;
  try {
    const sql = `
      UPDATE exams
        SET examcode = ?
          , module_id = ?
          , lesson_id = ?
          , maxscore = ?
          , examminute = ?
          , title = ?
          , caption = ?
          , descr = ?
          , coverid = ?
          , maturityrating = ?
          , tags = ?
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      examcode, 
      module_id, 
      lesson_id, 
      maxscore, 
      examminute, 
      title, 
      caption, 
      descr, 
      coverid, 
      maturityrating, 
      tags, 
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':update_exam', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function update_quiz(
  id: number,
  exam_id: number,
  quizno: number,
  quizminute: number,
  question: string,
  contentid: string,
  mediaid: string
) {
  let affectedRows = 0;
  try {
    const sql = `
      UPDATE quizzes
        SET exam_id = ?
          , quizno = ?
          , quizminute = ?
          , question = ?
          , contentid = ?
          , mediaid = ?
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      exam_id, 
      quizno, 
      quizminute, 
      question, 
      contentid, 
      mediaid, 
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':update_quiz', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function delete_module(id: number) {
  let affectedRows = 0;
  try {
    const sql = `
      DELETE FROM modules
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':delete_module', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function delete_lesson(id: number) {
  let affectedRows = 0;
  try {
    const sql = `
      DELETE FROM lessons
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':delete_lesson', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function delete_lessons(module_id: number) {
  let affectedRows = 0;
  try {
    const sql = `
      DELETE FROM lessons
        WHERE module_id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      module_id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':delete_lessons', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function delete_exam(id: number) {
  let affectedRows = 0;
  try {
    const sql = `
      DELETE FROM exams
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':delete_exam', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function delete_quiz(id: number) {
  let affectedRows = 0;
  try {
    const sql = `
      DELETE FROM quizzes
        WHERE id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':delete_quiz', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function delete_quizzes(exam_id: number) {
  let affectedRows = 0;
  try {
    const sql = `
      DELETE FROM quizzes
        WHERE exam_id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      exam_id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':delete_quizzes', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function delete_choices(quiz_id: number) {
  let affectedRows = 0;
  try {
    const sql = `
      DELETE FROM choices
        WHERE quiz_id = ?;
    `;
    const result = await dbconnect.execute(sql, [
      quiz_id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':delete_choices', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function delete_choices_by_exam_id(exam_id: number) {
  let affectedRows = 0;
  try {
    const sql = `
      DELETE FROM choices
        WHERE quiz_id IN (SELECT id FROM quizzes WHERE exam_id = ?);
    `;
    const result = await dbconnect.execute(sql, [
      exam_id
    ]); // OkPacket { affectedRows: 1, insertId: 0n, warningStatus: 0 }
    if (result.affectedRows) {
      affectedRows = xNumber(result.affectedRows);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':delete_choices_by_exam_id', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return affectedRows;
}

async function count_modules(
  belocked: any,
  becancelled: any,
  docstatus: any,
  modulecode: string,
  title: string,
  caption: string,
  descr: string,
  maturityrating: any,
  tags: any
) {
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (isData(belocked)) {
    whereclause += " AND belocked = ?";
    argumentarr.push(xNumber(belocked));
  }
  if (isData(becancelled)) {
    whereclause += " AND becancelled = ?";
    argumentarr.push(xNumber(becancelled));
  }
  if (isData(docstatus)) {
    whereclause += " AND docstatus = ?";
    argumentarr.push(xNumber(docstatus));
  }
  if (modulecode) {
    whereclause += " AND modulecode LIKE ?";
    argumentarr.push('%'+modulecode.trim()+'%');
  }
  if (title) {
    whereclause += " AND title LIKE ?";
    argumentarr.push('%'+title.trim()+'%');
  }
  if (caption) {
    whereclause += " AND caption LIKE ?";
    argumentarr.push('%'+caption.trim()+'%');
  }
  if (descr) {
    whereclause += " AND descr LIKE ?";
    argumentarr.push('%'+descr.trim()+'%');
  }
  if (isData(maturityrating)) {
    whereclause += " AND maturityrating = ?";
    argumentarr.push(xNumber(maturityrating));
  }
  if (isData(tags)) {
    const tagarr = toArray(tags);
    if (tagarr.length > 0) {
      whereclause += " AND (";
      for (let i = 0; i < tagarr.length; i++) {
        if (i > 0) {
          whereclause += " OR";
        }
        whereclause += " LOWER(tags) LIKE LOWER(?)";
        argumentarr.push('%"'+tagarr[i]+'"%');
      }
      whereclause += ")";
    }
  }
  // Execute SQL
  let RecordCount = 0;
  try {
    const sql = `
      SELECT COUNT(id) AS RecordCount
        FROM modules
        ${whereclause};
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      RecordCount = xNumber(result[0].RecordCount);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':count_modules', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return RecordCount;
}

async function count_lessons(
  module_id: number,
  lessoncode: string,
  title: string,
  descr: string,
  tags: string
) {
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (isData(module_id)) {
    whereclause += " AND module_id = ?";
    argumentarr.push(xNumber(module_id));
  }
  if (lessoncode) {
    whereclause += " AND lessoncode LIKE ?";
    argumentarr.push('%'+lessoncode.trim()+'%');
  }
  if (title) {
    whereclause += " AND title LIKE ?";
    argumentarr.push('%'+title.trim()+'%');
  }
  if (descr) {
    whereclause += " AND descr LIKE ?";
    argumentarr.push('%'+descr.trim()+'%');
  }
  if (isData(tags)) {
    const tagarr = toArray(tags);
    if (tagarr.length > 0) {
      whereclause += " AND (";
      for (let i = 0; i < tagarr.length; i++) {
        if (i > 0) {
          whereclause += " OR";
        }
        whereclause += " LOWER(tags) LIKE LOWER(?)";
        argumentarr.push('%"'+tagarr[i]+'"%');
      }
      whereclause += ")";
    }
  }
  // Execute SQL
  let RecordCount = 0;
  try {
    const sql = `
      SELECT COUNT(id) AS RecordCount
        FROM lessons
        ${whereclause};
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      RecordCount = xNumber(result[0].RecordCount);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':count_lessons', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return RecordCount;
}

async function count_exams(
  belocked: any,
  becancelled: any,
  docstatus: any,
  examcode: string,
  module_id: any,
  lesson_id: any,
  title: string,
  caption: string,
  descr: string,
  maturityrating: any,
  tags: any
) {
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (isData(belocked)) {
    whereclause += " AND belocked = ?";
    argumentarr.push(xNumber(belocked));
  }
  if (isData(becancelled)) {
    whereclause += " AND becancelled = ?";
    argumentarr.push(xNumber(becancelled));
  }
  if (isData(docstatus)) {
    whereclause += " AND docstatus = ?";
    argumentarr.push(xNumber(docstatus));
  }
  if (examcode) {
    whereclause += " AND examcode LIKE ?";
    argumentarr.push('%'+examcode.trim()+'%');
  }
  if (isData(module_id)) {
    whereclause += " AND module_id = ?";
    argumentarr.push(xNumber(module_id));
  }
  if (isData(lesson_id)) {
    whereclause += " AND lesson_id = ?";
    argumentarr.push(xNumber(lesson_id));
  }
  if (title) {
    whereclause += " AND title LIKE ?";
    argumentarr.push('%'+title.trim()+'%');
  }
  if (caption) {
    whereclause += " AND caption LIKE ?";
    argumentarr.push('%'+caption.trim()+'%');
  }
  if (descr) {
    whereclause += " AND descr LIKE ?";
    argumentarr.push('%'+descr.trim()+'%');
  }
  if (isData(maturityrating)) {
    whereclause += " AND maturityrating = ?";
    argumentarr.push(xNumber(maturityrating));
  }
  if (isData(tags)) {
    const tagarr = toArray(tags);
    if (tagarr.length > 0) {
      whereclause += " AND (";
      for (let i = 0; i < tagarr.length; i++) {
        if (i > 0) {
          whereclause += " OR";
        }
        whereclause += " LOWER(tags) LIKE LOWER(?)";
        argumentarr.push('%"'+tagarr[i]+'"%');
      }
      whereclause += ")";
    }
  }
  // Execute SQL
  let RecordCount = 0;
  try {
    const sql = `
      SELECT COUNT(id) AS RecordCount
        FROM exams
        ${whereclause};
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      RecordCount = xNumber(result[0].RecordCount);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':count_exams', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return RecordCount;
}

async function count_quizzes(
  belocked: any,
  becancelled: any,
  docstatus: any,
  exam_id: any,
  question: string
) {
  // Prepare SQL
  let whereclause = " WHERE 1";
  let argumentarr = [];
  if (isData(belocked)) {
    whereclause += " AND belocked = ?";
    argumentarr.push(xNumber(belocked));
  }
  if (isData(becancelled)) {
    whereclause += " AND becancelled = ?";
    argumentarr.push(xNumber(becancelled));
  }
  if (isData(docstatus)) {
    whereclause += " AND docstatus = ?";
    argumentarr.push(xNumber(docstatus));
  }
  if (isData(exam_id)) {
    whereclause += " AND exam_id = ?";
    argumentarr.push(xNumber(exam_id));
  }
  if (question) {
    whereclause += " AND question LIKE ?";
    argumentarr.push('%'+question.trim()+'%');
  }
  // Execute SQL
  let RecordCount = 0;
  try {
    const sql = `
      SELECT COUNT(id) AS RecordCount
        FROM quizzes
        ${whereclause};
    `;
    const result = await dbconnect.execute(sql, argumentarr);
    if (result.length > 0) {
      RecordCount = xNumber(result[0].RecordCount);
    }
  } catch (err) {
    console.log(incident(THIS_FILENAME+':count_quizzes', String(err)));
    return K.SYS_INTERNAL_PROCESS_ERROR;
  }
  return RecordCount;
}

export {
  add_module,
  add_lesson,
  add_exam,
  add_quiz,
  add_choice,
  get_sysvar,
  get_sysvars,
  get_module,
  get_modules,
  get_lesson,
  get_lessons,
  get_exam,
  get_exams,
  get_quiz,
  get_quizzes,
  get_choices,
  update_sysvar,
  update_module,
  update_lesson,
  update_exam,
  update_quiz,
  delete_module,
  delete_lesson,
  delete_lessons,
  delete_exam,
  delete_quiz,
  delete_quizzes,
  delete_choices,
  delete_choices_by_exam_id,
  count_modules,
  count_lessons,
  count_exams,
  count_quizzes,
}